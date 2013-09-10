# encoding: UTF-8
Encoding.default_internal = 'UTF-8'
require 'json'
require 'time'
require 'cgi'
require 'fileutils'
require 'ostruct'
require 'delegate'
require 'digest'
require 'observer'

require 'mustache'

require 'ruhoh/logger'
require 'ruhoh/utils'
require 'ruhoh/friend'
require 'ruhoh/parse'

require 'ruhoh/converter'
require 'ruhoh/views/master_view'
require 'ruhoh/collections'
require 'ruhoh/cache'
require 'ruhoh/routes'
require 'ruhoh/string_format'
require 'ruhoh/url_slug'
require 'ruhoh/programs/preview'

class Ruhoh
  class << self
    attr_accessor :log
    attr_reader :names, :root
  end

  attr_accessor :log, :env
  attr_reader :config, :paths, :root, :base, :cache, :collections, :routes

  Root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  @log = Ruhoh::Logger.new
  @root = Root

  def initialize
    @collections = Ruhoh::Collections.new(self)
    @cache = Ruhoh::Cache.new(self)
    @routes = Ruhoh::Routes.new(self)
  end

  def master_view(pointer)
    Ruhoh::Views::MasterView.new(self, pointer)
  end

  # Public: Setup Ruhoh utilities relative to the current application directory.
  # Returns boolean on success/failure
  def setup(opts={})
    self.class.log.log_file = opts[:log_file] if opts[:log_file] #todo
    @base = opts[:source] ? opts[:source] : Dir.getwd
    !!config
  end

  def collection(resource)
    @collections.load(resource)
  end

  def config(reload=false)
    return @config unless (reload or @config.nil?)

    config = Ruhoh::Parse.data_file(@base, "config") || {}
    config['compiled'] = config['compiled'] ? File.expand_path(config['compiled']) : "compiled"

    config['_root'] ||= {}
    config['_root']['permalink'] ||= "/:relative_path/:filename"
    config['_root']['paginator'] ||= {}
    config['_root']['paginator']['url'] ||= "/index/"
    config['_root']['rss'] ||= {}
    config['_root']['rss']['url'] ||= "/"

    config['base_path'] = config['base_path'].to_s.strip
    if config['base_path'].empty?
      config['base_path'] = '/'
    else
      config['base_path'] += "/" unless config['base_path'][-1] == '/'
    end

    @config = config
  end

  Paths = Struct.new(:base, :theme, :system, :compiled)
  def setup_paths
    @paths = Paths.new
    @paths.base = @base
    @paths.system = File.join(Ruhoh::Root, "system")
    @paths.compiled = @config["compiled"]

    theme = @config.find{ |resource, data| data['use'] == "theme" }
    if theme
      Ruhoh::Friend.say { plain "Using theme: \"#{theme[0]}\""}
      @paths.theme = File.join(@base, theme[0])
    end

    @paths
  end

  # Default paths to the 3 levels of the cascade.
  def cascade
    a = [
      {
        "name" => "system",
        "path" => paths.system
      },
      {
        "name" => "base",
        "path" => paths.base
      }
    ]
    a << {
      "name" => "theme",
      "path" => paths.theme
    } if paths.theme

    a
  end

  def setup_plugins
    ensure_paths

    enable_sprockets = @config['asset_pipeline']['enable'] rescue false
    if enable_sprockets
      Ruhoh::Friend.say { green "=> Oh boy! Asset pipeline enabled by way of sprockets =D" }
      sprockets = Dir[File.join(@paths.system, "plugins", "sprockets", "**/*.rb")]
      sprockets.each {|f| require f }
    end

    plugins = Dir[File.join(@base, "plugins", "**/*.rb")]
    plugins.each {|f| require f } unless plugins.empty?
  end

  def env
    @env || 'development'
  end

  def base_path
    (env == 'production') ?
      config['base_path'] :
      '/'
  end

  # @config['base_path'] is assumed to be well-formed.
  # Always remove trailing slash.
  # Returns String - normalized url with prepended base_path
  def to_url(*args)
    url = base_path + args.join('/')
    url = url.gsub(/\/{2,}/, '/')
    (url == "/") ? url : url.chomp('/')
  end

  def relative_path(filename)
    filename.gsub(Regexp.new("^#{@base}/"), '')
  end

  # Compile the ruhoh instance (save to disk).
  # Note: This method recursively removes the target directory. Should there be a warning?
  #
  # Extending:
  #   TODO: Deprecate this functionality and come up with a 2.0-friendly interface.
  #   The Compiler module is a namespace for all compile "tasks".
  #   A "task" is a ruby Class that accepts @ruhoh instance via initialize.
  #   At compile time all classes in the Ruhoh::Compiler namespace are initialized and run.
  #   To add your own compile task simply namespace a class under Ruhoh::Compiler
  #   and provide initialize and run methods:
  #
  #  class Ruhoh
  #    module Compiler
  #      class CustomTask
  #        def initialize(ruhoh)
  #          @ruhoh = ruhoh
  #        end
  #       
  #        def run
  #          # do something here
  #        end
  #      end
  #    end
  #  end
  def compile
    ensure_paths
    Ruhoh::Friend.say { plain "Compiling for environment: '#{@env}'" }
    FileUtils.rm_r @paths.compiled if File.exist?(@paths.compiled)
    FileUtils.mkdir_p @paths.compiled

    # Run the resource compilers
    compilers = @collections.all
    # Hack to ensure assets are processed first so post-processing logic reflects in the templates.
    compilers.delete('stylesheets')
    compilers.unshift('stylesheets')
    compilers.delete('javascripts')
    compilers.unshift('javascripts')

    compilers.each do |name|
      collection = collection(name)
      next unless collection.compiler?
      collection.load_compiler.run
    end

    # Run extra compiler tasks if available:
    if Ruhoh.const_defined?(:Compiler)
      Ruhoh::Compiler.constants.each {|c|
        compiler = Ruhoh::Compiler.const_get(c)
        next unless compiler.respond_to?(:new)
        task = compiler.new(self)
        next unless task.respond_to?(:run)
        task.run
      }
    end

    true
  end

  # Find a file in the base cascade directories
  # @return[Hash, nil] a single file pointer
  def find_file(key)
    dict = _all_files
    dict[key] || dict.values.find{ |a| key == a['id'].gsub(/.[^.]+$/, '') }
  end

  # Collect all files from the base bascade directories.
  # @return[Hash] dictionary of file pointers
  def _all_files
    dict = {}
    cascade.map{ |a| a['path'] }.each do |path|
      FileUtils.cd(path) { 
        Dir["*"].each { |id|
          next unless File.exist?(id) && FileTest.file?(id)
          dict[id] = {
            "id" => id,
            "realpath" => File.realpath(id),
          }
        }
      }
    end

    dict
  end

  def ensure_setup
    return if @config && @paths
    raise 'Ruhoh has not been fully setup. Please call: Ruhoh.setup'
  end

  def ensure_paths
    return if @config && @paths
    raise 'Ruhoh has not setup paths. Please call: Ruhoh.setup'
  end

  def self.collection(resource)
    Collections.load(resource)
  end

  def self.model(resource)
    Collections.get_module_namespace_for(resource).const_get(:ModelView)
  end
end
