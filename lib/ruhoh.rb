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

require 'ruhoh/views/rmustache'
require 'ruhoh/views/helpers/page'
require 'ruhoh/views/master'

require 'ruhoh/db'

class Ruhoh::Views::RMustache
  Ruhoh::Resources::Resource.resources.keys.each do |name|
    class_eval <<-RUBY
      def to_#{name}(sub_context)
        Array(sub_context).map { |id|
          @ruhoh.db.#{name}[id]
        }.compact
      end
    RUBY
  end
end

class Ruhoh::Views::Master
  Ruhoh::Resources::Resource.resources.each do |name, klass|
    next unless klass.const_defined?(:View)
    
    class_eval <<-RUBY
      def #{name}
        #{klass.const_get(:View)}.new(@ruhoh, context)
      end
    RUBY
  end
end

require 'ruhoh/converter'
require 'ruhoh/page'
require 'ruhoh/watch'
require 'ruhoh/program'

class Ruhoh
  class << self
    attr_accessor :log
    attr_reader :names, :root
  end
  
  attr_accessor :log
  attr_reader :config, :paths, :root, :base, :db

  Root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  @log = Ruhoh::Logger.new
  @root = Root
  
  def initialize
    @db = Ruhoh::DB.new(self)
  end
  
  def page(route)
    Page.new(self, route)
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
      config['base_path'] += "/" unless config['base_path'][-1] == '/'
    else
      config['base_path'] = '/'
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
  
  # @config['base_path'] is assumed to be well-formed.
  # Always remove trailing slash.
  # Returns String - normalized url with prepended base_path
  def to_url(*args)
    url = args.join('/').chomp('/').reverse.chomp('/').reverse
    url = @config['base_path'] + url
  end
  
  def relative_path(filename)
    filename.gsub(Regexp.new("^#{@base}/"), '')
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