# encoding: UTF-8
Encoding.default_internal = 'UTF-8'
require 'yaml'
require 'psych'
YAML::ENGINE.yamler = 'psych'

require 'json'
require 'time'
require 'cgi'
require 'fileutils'
require 'ostruct'

require 'mustache'

require 'ruhoh/logger'
require 'ruhoh/utils'
require 'ruhoh/friend'

require 'ruhoh/converter'

module Ruhoh::Resources ; end
module Ruhoh::Views ; end
module Ruhoh::Views::Helpers ; end

require 'ruhoh/views/master_view'

require 'ruhoh/resources_interface'
require 'ruhoh/db'

class Ruhoh::Views::MasterView
  Ruhoh::Resources::Base::Collection.resources.each do |name, namespace|
    if namespace.const_defined?(:CollectionView)
      class_eval <<-RUBY
        def #{name}
          return @#{name} if @#{name}
          @#{name} = @ruhoh.resources.load_collection_view('#{name}')
          @#{name}.master = self
          @#{name}
        end
      RUBY
    else
      class_eval <<-RUBY
        def #{name}
          nil
        end
      RUBY
    end

    class_eval <<-RUBY
      def to_#{name}(sub_context)
        collection_view = #{name}
        Array(sub_context).map { |id|
          data = @ruhoh.db.#{name}[id]
          collection_view ? collection_view.new_model_view(data) : data
        }.compact
      end
    RUBY
    
  end
end

require 'ruhoh/programs/preview'

class Ruhoh
  class << self
    attr_accessor :log
    attr_reader :names, :root
  end
  
  attr_accessor :log, :env
  attr_reader :config, :paths, :root, :base, :db, :resources

  Root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  @log = Ruhoh::Logger.new
  @root = Root
  
  def initialize
    @resources = Ruhoh::ResourcesInterface.new(self)
    @db = Ruhoh::DB.new(self)
  end
  
  def master_view(pointer)
    Ruhoh::Views::MasterView.new(self, pointer)
  end
  
  # Public: Setup Ruhoh utilities relative to the current application directory.
  # Returns boolean on success/failure
  def setup(opts={})
    self.reset
    @log.log_file = opts[:log_file] if opts[:log_file] #todo
    @base = opts[:source] if opts[:source]
    !!self.config
  end
  
  def reset
    @base = Dir.getwd
  end
  
  def config
    return @config if @config
    config = Ruhoh::Utils.parse_yaml_file(@base, "config.yml")
    unless config
      Ruhoh.log.error("Empty config.\nEnsure ./#{"config.yml"} exists and contains valid YAML")
      return false
    end

    config['compiled'] = config['compiled'] ? File.expand_path(config['compiled']) : "compiled"

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
    self.ensure_config
    @paths = Paths.new
    @paths.base = @base
    @paths.theme = File.join(@base, "themes", self.db.config('theme')['name'])
    @paths.system = File.join(Ruhoh::Root, "system")
    @paths.compiled = @config["compiled"]
    @paths
  end
  
  def setup_plugins
    self.ensure_paths
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
    url = url.gsub(/\/\//, '/')
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
    @resources.all.keys.each do |name|
      next unless @resources.compiler?(name)
      @resources.load_compiler(name).run
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
  
  def ensure_setup
    return if @config && @paths
    raise 'Ruhoh has not been fully setup. Please call: Ruhoh.setup'
  end  
  
  def ensure_config
    return if @config
    raise 'Ruhoh has not setup config. Please call: Ruhoh.setup'
  end  

  def ensure_paths
    return if @config && @paths
    raise 'Ruhoh has not setup paths. Please call: Ruhoh.setup'
  end  
  
end # Ruhoh