require 'yaml'
require 'json'
require 'time'
require 'cgi'
require 'fileutils'

require 'mustache'

require 'ruhoh/utils'
require 'ruhoh/parsers/posts'
require 'ruhoh/parsers/pages'
require 'ruhoh/parsers/routes'
require 'ruhoh/parsers/layouts'
require 'ruhoh/parsers/partials'
require 'ruhoh/parsers/site'
require 'ruhoh/db'
require 'ruhoh/templaters/helper_mustache'
require 'ruhoh/templaters/templater'
require 'ruhoh/converters/converter'
require 'ruhoh/page'
require 'ruhoh/preview'
require 'ruhoh/watch'

class Ruhoh

  class << self; attr_reader :folders, :files, :config, :paths, :filters end
  
  Folders = Struct.new(:database, :posts, :templates, :themes, :layouts, :partials, :media)
  Files = Struct.new(:site, :config)
  Filters = Struct.new(:posts, :pages, :static)
  Config = Struct.new(:permalink, :theme, :asset_path)
  Paths = Struct.new(
    :site_source,
    :database,
    :posts,
    :theme,
    :layouts,
    :partials,
    :global_partials,
    :media
  )
  
  # Public: Setup Ruhoh utilities relative to the current directory
  # of the application and its corresponding ruhoh.json file.
  #
  def self.setup(site_source = nil)
    @folders    = Folders.new('_database', '_posts', '_templates', 'themes', 'layouts', 'partials', "_media")
    @files      = Files.new('_site.yml', '_config.yml')
    @filters    = Filters.new
    @config     = Config.new
    @paths      = Paths.new
    
    config = { 'site_source' => site_source || Dir.getwd }
    site_config = YAML.load_file( File.join(config['site_source'], '_config.yml') )

    @config.permalink         = site_config['permalink'] || :date
    @config.theme             = site_config['theme']
    @config.asset_path        = File.join('/', @folders.templates, @folders.themes, @config.theme)
    
    @paths.site_source = config['site_source']
    @paths.database    = self.absolute_path(@folders.database)
    @paths.posts       = self.absolute_path(@folders.posts)

    @paths.theme       = self.absolute_path(@folders.templates, @folders.themes, @config.theme)
    @paths.layouts     = self.absolute_path(@folders.templates, @folders.themes, @config.theme, @folders.layouts)
    @paths.partials    = self.absolute_path(@folders.templates, @folders.themes, @config.theme, @folders.partials)
    @paths.global_partials = self.absolute_path(@folders.templates, @folders.partials)
    @paths.media = self.absolute_path(@folders.media)
    

    # filename filters:
    @filters.pages = { 'names' => [], 'regexes' => [] }
    exclude = ['Gemfile', 'Gemfile.lock', 'config.ru', 'README.md']
    exclude.each {|node| 
      @filters.pages['names'] << node if node.is_a?(String)
      @filters.pages['regexes'] << node if node.is_a?(Regexp)
    }
  end
  
  def self.absolute_path(*args)
    File.__send__ :join, args.unshift(self.paths.site_source)
  end
    
end # Ruhoh  
