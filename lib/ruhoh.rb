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
require 'ruhoh/converters/converter'
require 'ruhoh/page'
require 'ruhoh/previewer'
require 'ruhoh/watch'
require 'ruhoh/program'

class Ruhoh
  
  class << self
    attr_accessor :log
    attr_reader :config, :names, :paths, :root, :urls, :base
  end
  
  @log = Ruhoh::Logger.new
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
  @names = OpenStruct.new(Names)
  @root = Root
  
  # Public: Setup Ruhoh utilities relative to the current application directory.
  # Returns boolean on success/failure
  def self.setup(opts={})
    self.reset
    @log.log_file = opts[:log_file] if opts[:log_file]
    @base = opts[:source] if opts[:source]
    @config = Ruhoh::Config.generate
    !!@config
  end
  
  def self.reset
    @base = Dir.getwd
  end
  
  def self.setup_paths
    self.ensure_config
    @paths = Ruhoh::Paths.generate
  end

  def self.setup_urls
    self.ensure_config
    @urls = Ruhoh::Urls.generate
  end
  
  def self.setup_plugins
    self.ensure_paths
    plugins = Dir[File.join(self.paths.plugins, "**/*.rb")]
    plugins.each {|f| require f } unless plugins.empty?
  end
  
  def self.ensure_setup
    return if Ruhoh.config && Ruhoh.paths && Ruhoh.urls
    raise 'Ruhoh has not been fully setup. Please call: Ruhoh.setup'
  end  
  
  def self.ensure_config
    return if Ruhoh.config
    raise 'Ruhoh has not setup config. Please call: Ruhoh.setup'
  end  

  def self.ensure_paths
    return if Ruhoh.config && Ruhoh.paths
    raise 'Ruhoh has not setup paths. Please call: Ruhoh.setup'
  end  
  
  def self.ensure_urls
    return if Ruhoh.config && Ruhoh.urls
    raise 'Ruhoh has not setup urls. Please call: Ruhoh.setup + Ruhoh.setup_urls' 
  end  
  
  
end # Ruhoh