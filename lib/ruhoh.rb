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
require 'ruhoh/converters/converter'
require 'ruhoh/page'
require 'ruhoh/previewer'
require 'ruhoh/watch'

class Ruhoh

  class << self
    attr_accessor :log
    attr_reader :folders, :files, :config, :paths, :filters
  end
  
  @log = Ruhoh::Logger.new
  
  Root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  DefaultExclude = ['Gemfile', 'Gemfile.lock', 'config.ru', 'README.md']
  Folders = Struct.new(:database, :pages, :posts, :templates, :themes, :layouts, :partials, :media, :syntax, :compiled)
  Files = Struct.new(:site, :config)
  Filters = Struct.new(:posts, :pages, :static)
  Config = Struct.new(:permalink, :theme, :theme_path, :media_path, :syntax_path, :exclude, :env)
  Paths = Struct.new(
    :site_source,
    :database,
    :pages,
    :posts,
    :theme,
    :layouts,
    :partials,
    :global_partials,
    :media,
    :syntax,
    :compiled
  )
  
  
  # Public: Setup Ruhoh utilities relative to the current application directory.
  # Returns boolean on success/failure
  def self.setup(opts={})
    @log.log_file = opts[:log_file] if opts[:log_file]
    self.reset
    @site_source = opts[:source] if opts[:source]

    !!(self.setup_config && self.setup_paths && self.setup_filters)
  end
  
  def self.reset
    @folders     = Folders.new('_database', '_pages', '_posts', '_templates', 'themes', 'layouts', 'partials', "_media", "syntax", '_compiled')
    @files       = Files.new('_site.yml', '_config.yml')
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
    @config.theme_path    = File.join('/', @folders.templates, @folders.themes, @config.theme)
    @config.media_path    = File.join('/', @folders.media)
    @config.syntax_path   = File.join('/', @folders.templates, @folders.syntax)
    @config.permalink     = site_config['permalink']
    @config.exclude       = Array(site_config['exclude'] || nil)
    @config.env           = site_config['env'] || nil
    @config
  end
  
  def self.setup_paths
    @paths.site_source      = @site_source
    @paths.database         = self.absolute_path(@folders.database)
    @paths.pages            = self.absolute_path(@folders.pages)
    @paths.posts            = self.absolute_path(@folders.posts)

    @paths.theme            = self.absolute_path(@folders.templates, @folders.themes, @config.theme)
    @paths.layouts          = self.absolute_path(@folders.templates, @folders.themes, @config.theme, @folders.layouts)
    @paths.partials         = self.absolute_path(@folders.templates, @folders.themes, @config.theme, @folders.partials)
    @paths.global_partials  = self.absolute_path(@folders.templates, @folders.partials)
    @paths.media            = self.absolute_path(@folders.media)
    @paths.syntax           = self.absolute_path(@folders.templates, @folders.syntax)
    @paths.compiled         = self.absolute_path(@folders.compiled)
    @paths
  end
  
  # filename filters
  def self.setup_filters
    exclude = @config.exclude + DefaultExclude
    exclude.uniq!
    
    @filters.pages = { 'names' => [], 'regexes' => [] }
    exclude.each {|node| 
      @filters.pages['names'] << node if node.is_a?(String)
      @filters.pages['regexes'] << node if node.is_a?(Regexp)
    }
    @filters
  end
  
  def self.absolute_path(*args)
    File.__send__ :join, args.unshift(self.paths.site_source)
  end
  
  def self.relative_path(filename)
    filename.gsub( Regexp.new("^#{self.paths.site_source}/"), '' )
  end
    
end # Ruhoh  
