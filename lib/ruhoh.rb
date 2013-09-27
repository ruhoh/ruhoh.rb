# encoding: UTF-8
Encoding.default_internal = 'UTF-8'
require 'json'
require 'time'
require 'ruhoh/time'
require 'cgi'
require 'fileutils'
require 'ostruct'
require 'delegate'
require 'digest'
require 'observer'
require 'set'

require 'mustache'

require 'ruhoh/logger'
require 'ruhoh/utils'
require 'ruhoh/friend'
require 'ruhoh/parse'

require 'ruhoh/config'
require 'ruhoh/cascade'
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
    attr_reader :root
  end

  attr_accessor :log, :env
  attr_reader :root, :cache, :collections, :routes

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

  def setup(opts={})
    self.class.log.log_file = opts[:log_file] if opts[:log_file] #todo
    @base = opts[:source] ? opts[:source] : Dir.getwd
  end

  def collection(resource)
    @collections.load(resource)
  end

  def config
    @config ||= Ruhoh::Config.new(self)
  end

  def cascade
    return @cascade if @cascade

    @cascade = Ruhoh::Cascade.new(config)
    @cascade.base = @base
    config.touch

    @cascade
  end

  def setup_plugins
    enable_sprockets = config['asset_pipeline']['enable'] rescue false
    if enable_sprockets
      Ruhoh::Friend.say { green "=> Oh boy! Asset pipeline enabled by way of sprockets =D" }
      sprockets = Dir[File.join(cascade.system, "plugins", "sprockets", "**/*.rb")]
      sprockets.each {|f| require f }
    end

    plugins = Dir[File.join(@base, "plugins", "**/*.rb")]
    plugins.each {|f| require f } unless plugins.empty?
  end

  def env
    @env || 'development'
  end

  def compiled_path(url)
    if config['compile_as_root']
      url = url.gsub(/^#{ config.base_path.chomp('/') }\/?/, '')
    end

    path = File.expand_path(File.join(config['compiled'], url)).gsub(/\/{2,}/, '/')
    CGI.unescape(path)
  end

  # Always remove trailing slash.
  # Returns String - normalized url with prepended base_path
  def to_url(*args)
    url = config.base_path + args.join('/')
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
    Ruhoh::Friend.say { plain "Compiling for environment: '#{@env}'" }
    FileUtils.rm_r config['compiled'] if File.exist?(config['compiled'])
    FileUtils.mkdir_p config['compiled']

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

  def self.collection(resource)
    Collections.load(resource)
  end

  def self.model(resource)
    Collections.get_module_namespace_for(resource).const_get(:ModelView)
  end
end
