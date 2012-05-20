# encoding: UTF-8
Encoding.default_internal = 'UTF-8'
require 'yaml'
require 'psych'
YAML::ENGINE.yamler = 'psych'

require 'json'
require 'time'
require 'cgi'
require 'fileutils'

require 'mustache'

require 'ruhoh/logger'
require 'ruhoh/utils'
require 'ruhoh/friend'
require 'ruhoh/parsers/posts'
require 'ruhoh/parsers/pages'
require 'ruhoh/parsers/routes'
require 'ruhoh/parsers/layouts'
require 'ruhoh/parsers/partials'
require 'ruhoh/parsers/site'
require 'ruhoh/db'
require 'ruhoh/templaters/helpers'
require 'ruhoh/templaters/rmustache'
require 'ruhoh/templaters/base'
require 'ruhoh/converters/markdown'
require 'ruhoh/converters/converter'
require 'ruhoh/page'
require 'ruhoh/previewer'
require 'ruhoh/watch'
require 'ruhoh/program'

class Ruhoh
  
  class << self
    attr_accessor :log
    attr_reader :folders, :files, :config, :paths, :filters
  end
  
  @log = Ruhoh::Logger.new

  Root      = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  Folders   = Struct.new(:database, :pages, :posts, :layouts, :assets, :partials, :media, :syntax, :compiled, :plugins)
  Files     = Struct.new(:site, :config, :dashboard)
  Filters   = Struct.new(:posts, :pages, :static)
  Config    = Struct.new(:permalink, :pages_permalink, :theme, :asset_path, :media_path, :syntax_path, :exclude, :env)
  Paths     = Struct.new(
                :site_source, :database, :pages, :posts, :theme, :layouts, :assets, :partials, :global_partials, :media, :syntax,
                :compiled, :dashboard, :plugins)
  
  
  # Public: Setup Ruhoh utilities relative to the current application directory.
  # Returns boolean on success/failure
  def self.setup(opts={})
    @log.log_file = opts[:log_file] if opts[:log_file]
    self.reset
    @site_source = opts[:source] if opts[:source]
    
    if (self.setup_config && self.setup_paths && self.setup_filters)
      self.setup_plugins unless opts[:enable_plugins] == false
      true
    else
      false
    end
  end
  
  def self.reset
    @folders     = Folders.new('_database', '_pages', '_posts', 'layouts', 'assets', '_partials', "_media", "_syntax", '_compiled', '_plugins')
    @files       = Files.new('_site.yml', '_config.yml', 'dash.html')
    @filters     = Filters.new
    @config      = Config.new
    @paths       = Paths.new
    @site_source = Dir.getwd
  end
  
  def self.setup_config
    site_config = Ruhoh::Utils.parse_file_as_yaml(@site_source, @files.config)
    
    unless site_config
      Ruhoh.log.error("Empty site_config.\nEnsure ./#{Ruhoh.files.config} exists and contains valid YAML")
      return false
    end
    
    theme = site_config['theme'] ? site_config['theme'].to_s.gsub(/\s/, '') : ''
    if theme.empty?
      Ruhoh.log.error("Theme not specified in _config.yml")
      return false
    end
    
    @config.theme         = theme
    @config.asset_path    = "/#{@config.theme}/#{@folders.assets}"
    @config.media_path    = "/#{@folders.media}"
    @config.syntax_path   = "/#{@folders.syntax}"
    @config.permalink     = site_config['permalink']
    @config.pages_permalink = site_config['pages']['permalink'] rescue nil
    excluded_pages = site_config['pages']['exclude'] rescue nil
    @config.exclude       = {
      "posts" => Array(site_config['exclude'] || nil),
      "pages" => Array(excluded_pages),
    }
    @config.env           = site_config['env'] || nil
    @config
  end
  
  def self.setup_paths
    @paths.site_source      = @site_source
    @paths.database         = self.absolute_path(@folders.database)
    @paths.pages            = self.absolute_path(@folders.pages)
    @paths.posts            = self.absolute_path(@folders.posts)

    @paths.theme            = self.absolute_path(@config.theme)
    @paths.layouts          = self.absolute_path(@config.theme, @folders.layouts)
    @paths.assets           = self.absolute_path(@config.theme, @folders.assets)
    @paths.partials         = self.absolute_path(@config.theme, @folders.partials)

    @paths.global_partials  = self.absolute_path(@folders.partials)
    @paths.media            = self.absolute_path(@folders.media)
    @paths.syntax           = self.absolute_path(@folders.syntax)
    @paths.compiled         = self.absolute_path(@folders.compiled)
    @paths.dashboard        = self.absolute_path(@files.dashboard)
    @paths.plugins          = self.absolute_path(@folders.plugins)
    @paths
  end
  
  # filename filters
  def self.setup_filters
    @filters.pages = @config.exclude['pages'].map {|node| Regexp.new(node) }
    @filters.posts = @config.exclude['posts'].map {|node| Regexp.new(node) }
    @filters
  end
  
  def self.setup_plugins
    plugins = Dir[File.join(self.paths.plugins, "**/*.rb")]
    plugins.each {|f| require f } unless plugins.empty?
  end
  
  def self.absolute_path(*args)
    File.__send__ :join, args.unshift(self.paths.site_source)
  end
  
  def self.relative_path(filename)
    filename.gsub( Regexp.new("^#{self.paths.site_source}/"), '' )
  end
    
  def self.ensure_setup
    raise 'Ruhoh has not been setup. Please call: Ruhoh.setup' unless Ruhoh.config && Ruhoh.paths
  end  
  
end # Ruhoh