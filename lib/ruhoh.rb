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
require 'ruhoh/config'
require 'ruhoh/paths'
require 'ruhoh/urls'
require 'ruhoh/db'
require 'ruhoh/templaters/rmustache'
require 'ruhoh/converter'
require 'ruhoh/page'
require 'ruhoh/previewer'
require 'ruhoh/watch'
require 'ruhoh/program'

class Ruhoh
  class << self
    attr_accessor :log
    attr_reader :names, :root
  end
  
  attr_accessor :log
  attr_reader :config, :paths, :root, :urls, :base, :db

  Root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  Names = {
    :assets => 'assets',
    :config_data => 'config.yml',
    :compiled => 'compiled',
    :dashboard_file => 'dash.html',
    :layouts => 'layouts',
    :media => 'media',
    :pages => 'pages',
    :partials => 'partials',
    :plugins => 'plugins',
    :posts => 'posts',
    :javascripts => 'javascripts',
    :scaffolds => 'scaffolds',
    :site_data => 'site.yml',
    :stylesheets => 'stylesheets',
    :system => 'system',
    :themes => 'themes',
    :theme_config => 'theme.yml',
    :widgets => 'widgets',
    :widget_config => 'config.yml'
  }

  @log = Ruhoh::Logger.new
  @names = OpenStruct.new(Names)
  @root = Root
  
  def initialize
    @db = Ruhoh::DB.new(self)
  end
  
  def page(id)
    Page.new(self, id)
  end
  
  # Public: Setup Ruhoh utilities relative to the current application directory.
  # Returns boolean on success/failure
  def setup(opts={})
    self.reset
    @log.log_file = opts[:log_file] if opts[:log_file] #todo
    @base = opts[:source] if opts[:source]
    @config = Ruhoh::Config.generate(self)
    !!@config
  end
  
  def reset
    @base = Dir.getwd
  end
  
  def setup_paths
    self.ensure_config
    @paths = Ruhoh::Paths.generate(self)
  end

  def setup_urls
    self.ensure_config
    @urls = Ruhoh::Urls.generate(self)
  end
  
  def setup_plugins
    self.ensure_paths
    plugins = Dir[File.join(@paths.plugins, "**/*.rb")]
    plugins.each {|f| require f } unless plugins.empty?
  end
  
  # ruhoh.config.base_path is assumed to be well-formed.
  # Always remove trailing slash.
  # Returns String - normalized url with prepended base_path
  def to_url(*args)
    url = args.join('/').chomp('/').reverse.chomp('/').reverse
    url = self.config.base_path + url
  end
  
  def ensure_setup
    return if @config && @paths && @urls
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
  
  def ensure_urls
    return if @config && @urls
    raise 'Ruhoh has not setup urls. Please call: Ruhoh.setup + Ruhoh.setup_urls' 
  end  
  
  
end # Ruhoh