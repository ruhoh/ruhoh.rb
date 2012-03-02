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
require 'ruhoh/db'
require 'ruhoh/templaters/helper_mustache'
require 'ruhoh/templaters/templater'
require 'ruhoh/page'
require 'ruhoh/preview'

class Ruhoh

  class << self; attr_accessor :config, :paths end
  
  Config = Struct.new(
    :site_source,
    :database_folder,
    :permalink,
    :theme,
    :asset_path
  )

  Paths = Struct.new(
    :site_source,
    :posts,
    :theme,
    :layouts,
    :partials,
    :posts_data,
    :pages_data,
  )

  # Public: Setup Ruhoh utilities relative to the current directory
  # of the application and its corresponding ruhoh.json file.
  #
  def self.setup
    @config = Config.new
    @paths = Paths.new

    config = File.open(File.join(Dir.getwd, 'ruhoh.json'), "r").read
    config = JSON.parse(config)
    site_config = YAML.load_file( File.join(config['site_source'], '_config.yml') )
    
    @config.site_source       = config['site_source']
    @config.permalink         = site_config['permalink'] || :date # default is date in jekyll
    @config.theme             = site_config['theme']
    @config.asset_path        = File.join('/', @config.site_source, '_themes', @config.theme)
    @config.database_folder   = '_database'
    
    @paths.site_source = File.join(Dir.getwd, @config.site_source)
    @paths.partials    = File.join(Dir.getwd, '_client', 'partials') # TODO: change this path
    @paths.posts       = self.absolute_path('_posts')
    @paths.theme       = self.absolute_path('_themes', @config.theme)
    @paths.layouts     = self.absolute_path('_themes', @config.theme, 'layouts')
    @paths.posts_data  = self.absolute_path(@config.database_folder, 'posts_dictionary.yml')
    @paths.pages_data  = self.absolute_path(@config.database_folder, 'pages_dictionary.yml')
  end
  
  def self.absolute_path(*args)
    File.__send__ :join, args.unshift(self.paths.site_source)
  end
    
end # Ruhoh  
