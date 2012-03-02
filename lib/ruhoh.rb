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
require 'ruhoh/watch'

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
  
  
  class HelperMustache < Mustache

    class HelperContext < Context
    
      # Overload find method to catch helper expressions
      def find(obj, key, default = nil)
        return super unless key.to_s.index('?')
      
        puts "=> Executing helper: #{key}"
        context, helper = key.to_s.split('?')
        context = context.empty? ? obj : super(obj, context)

        self.mustache_in_stack.__send__ helper, context
      end  

    end #HelperContext
  
    def context
      @context ||= HelperContext.new(self)
    end
  
    def partials
      @partials ||= Ruhoh::Database.get(:partials)
    end
  
    def partial(name)
      self.partials[name.to_s]
    end
  
    def to_tags(sub_context)
      if sub_context.is_a?(Array)
        sub_context.map { |id|
          self.context['_posts']['tags'][id] if self.context['_posts']['tags'][id]
        }
      else
        tags = []
        self.context['_posts']['tags'].each_value { |tag|
          tags << tag
        }
        tags
      end
    end
  
    def to_posts(sub_context)
      sub_context = sub_context.is_a?(Array) ? sub_context : self.context['_posts']['chronological']
    
      sub_context.map { |id|
        self.context['_posts']['dictionary'][id] if self.context['_posts']['dictionary'][id]
      }
    end
  
    def to_pages(sub_context)
      puts "=> call: pages_list with context: #{sub_context}"
      pages = []
      if sub_context.is_a?(Array) 
        sub_context.each do |id|
          if self.context[:pages][id]
            pages << self.context[:pages][id]
          end
        end
      else
        self.context[:pages].each_value {|page| pages << page }
      end
      pages
    end
  
  end #HelperMustache
  
  class Page
    attr_accessor :data, :content, :sub_layout, :master_layout

    def update(url)
      self.find(url)
      self.process_layouts
    end
    
    def find(url)
      url = '/index.html' if url == '/'
      id = Ruhoh::Database.get(:routes)[url]
      raise "Page id not found for url: #{url}" unless id
      
      @data = id =~ /^_posts/ ? Ruhoh::Database.get(:posts)['dictionary'][id] : Ruhoh::Database.get(:pages)[id]
      raise "Page #{id} not found in database" unless @data

      @content = Ruhoh::Utils.parse_file(id)['content']
    end
    
    # Layouts
    def process_layouts
      @sub_layout = Ruhoh::Database.get(:layouts)[@data['layout']]
      
      if @sub_layout['data']['layout']
        @master_layout = Ruhoh::Database.get(:layouts)[@sub_layout['data']['layout']]
      end
    end
    
    def render
      Ruhoh::Template.process(self)
    end
    
    def attributes
      {
        "data" => @data,
        "content" => @content
      }
    end
    
  end
  
  module Template
    
    def self.build_payload(page)
      {
        "page"    => page.attributes,
        "config"  => Ruhoh::Database.get(:config),
        "pages"   => Ruhoh::Database.get(:pages),
        "_posts"  => Ruhoh::Database.get(:posts),
        "ASSET_PATH" => File.join('/', Ruhoh.config.site_source, Ruhoh.config.theme_path ),
      }
    end
    
    def self.process(page)
      output = page.sub_layout['content'].gsub(Ruhoh::Utils::ContentRegex, page.content)

      # An undefined master means the page/post layouts is only one deep.
      # This means it expects to load directly into a master template.
      if page.master_layout && page.master_layout['content']
        output = page.master_layout['content'].gsub(Ruhoh::Utils::ContentRegex, output);
      end
      
      self.render(output, self.build_payload(page))
    end
    
    def self.render(output, payload)
      Ruhoh::HelperMustache.render(output, payload)
    end
    
  end
  
end # Ruhoh  
