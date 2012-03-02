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
require 'ruhoh/database'
require 'ruhoh/templaters/helper_mustache'
require 'ruhoh/templaters/templater'
require 'ruhoh/page'
require 'ruhoh/preview'

class Ruhoh

  class << self; attr_accessor :config end
  
  Config = Struct.new(
    :site_source,
    :site_source_path,
    :database_folder,
    :posts_path,
    :posts_data_path,
    :pages_data_path,
    :permalink,
    :theme,
    :theme_path
  )

  # Public: Setup Ruhoh utilities relative to the current directory
  # of the application and its corresponding ruhoh.json file.
  #
  def self.setup
    base_directory = Dir.getwd
    config = File.open(File.join(base_directory, 'ruhoh.json'), "r").read
    config = JSON.parse(config)
    site_config = YAML.load_file( File.join(config['site_source'], '_config.yml') )
    
    c = Config.new
    c.site_source = config['site_source']
    c.site_source_path = File.join(base_directory, c.site_source)
    c.database_folder = '_database'
    c.posts_path = File.join(c.site_source_path, '_posts')
    c.posts_data_path = File.join(c.site_source_path, c.database_folder, 'posts_dictionary.yml')
    c.pages_data_path = File.join(c.site_source_path, c.database_folder, 'pages_dictionary.yml')
    c.permalink = site_config['permalink'] || :date # default is date in jekyll
    c.theme = site_config['theme']
    c.theme_path = File.join('_themes', c.theme)
    
    self.config = c
  end
  
end # Ruhoh  
