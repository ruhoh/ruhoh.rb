require 'yaml'
require 'json'
require 'time'
require 'cgi'
require 'fileutils'

require 'mustache'

require 'ruhoh/utils'
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
  Ruhoh.setup
  
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
  
  module Routes

    #[{"url" => "id"}, ... ]
    def self.generate
      routes = {}
      Ruhoh::Pages.generate.each_value { |page|
        routes[page['url']] = page['id'] 
      }
      Ruhoh::Posts.generate['dictionary'].each_value { |page|
        routes[page['url']] = page['id'] 
      }
      
      routes
    end
    
  end #Routes
  
  module Posts
    
    MATCHER = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/

    # Public: Generate the Posts dictionary.
    #
    def self.generate
      raise "Ruhoh.config cannot be nil.\n To set config call: Ruhoh.setup" unless Ruhoh.config
      puts "=> Generating Posts..."

      dictionary, invalid_posts = process_posts
      ordered_posts = []
      dictionary.each_value { |val| ordered_posts << val }
      
      ordered_posts.sort! {
        |a,b| Date.parse(b['date']) <=> Date.parse(a['date'])
      }
      
      data = {
        'dictionary' => dictionary,
        'chronological' => build_chronology(ordered_posts),
        'collated' => collate(ordered_posts),
        'tags' => parse_tags(ordered_posts),
        'categories' => parse_categories(ordered_posts)
      }

      open(Ruhoh.config.posts_data_path, 'w') { |page|
        page.puts data.to_yaml
      }
  
      if invalid_posts.empty?
        puts "=> #{dictionary.count}/#{dictionary.count + invalid_posts.count} posts processed."
      else
        puts "=> Invalid posts not processed:"
        puts invalid_posts.to_yaml
      end
      
      data
    end

    def self.process_posts
      dictionary = {}
      invalid_posts = []

      FileUtils.cd(Ruhoh.config.site_source_path) {
        Dir.glob("_posts/**/*.*") { |filename| 
          next if FileTest.directory?(filename)
          next if ['.'].include? filename[0]

          File.open(filename) do |page|
            front_matter = page.read.match(Ruhoh::Utils::FMregex)
            if !front_matter
              invalid_posts << filename ; next
            end
        
            post = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
            
            m, path, file_date, file_slug, ext = *filename.match(MATCHER)
            post['date'] = post['date'] || file_date

            ## Test for valid date
            begin 
              Time.parse(post['date'])
            rescue
              puts "Invalid date format on: #{filename}"
              puts "Date should be: YYYY/MM/DD"
              invalid_posts << filename
              next
            end
            
            post['id'] = filename
            post['title'] = post['title'] || self.titleize(file_slug)
            post['url'] = self.permalink(post)
            dictionary[filename] = post
          end
        }
      }

      [dictionary, invalid_posts]
    end
    
    # my-post-title ===> My Post Title
    def self.titleize(file_slug)
      file_slug.gsub(/[\W\_]/, ' ').gsub(/\b\w/){$&.upcase}
    end
    
    # Another blatently stolen method from Jekyll
    def self.permalink(post)
      date = Date.parse(post['date'])
      title = post['title'].downcase.gsub(' ', '-').gsub('.','')
      format = case (post['permalink'] || Ruhoh.config.permalink)
      when :pretty
        "/:categories/:year/:month/:day/:title/"
      when :none
        "/:categories/:title.html"
      when :date
        "/:categories/:year/:month/:day/:title.html"
      else
        post['permalink'] || Ruhoh.config.permalink
      end
      
      url = {
        "year"       => date.strftime("%Y"),
        "month"      => date.strftime("%m"),
        "day"        => date.strftime("%d"),
        "title"      => CGI::escape(title),
        "i_day"      => date.strftime("%d").to_i.to_s,
        "i_month"    => date.strftime("%m").to_i.to_s,
        "categories" => Array(post['categories'] || post['category']).join('/'),
        "output_ext" => 'html' # what's this for?
      }.inject(format) { |result, token|
        result.gsub(/:#{Regexp.escape token.first}/, token.last)
      }.gsub(/\/\//, "/")

      # sanitize url
      url = url.split('/').reject{ |part| part =~ /^\.+$/ }.join('/')
      url += "/" if url =~ /\/$/
      url
    end
    
    def self.build_chronology(posts)
      posts.map { |post| post['id'] }
    end

    # Internal: Create a collated posts data structure.
    #
    # posts - Required [Array] 
    #  Must be sorted chronologically beforehand.
    #
    # [{ 'year': year, 
    #   'months' : [{ 'month' : month, 
    #     'posts': [{}, {}, ..] }, ..] }, ..]
    # 
    def self.collate(posts)
      collated = []
      posts.each_with_index do |post, i|
        thisYear = Time.parse(post['date']).strftime('%Y')
        thisMonth = Time.parse(post['date']).strftime('%B')
        if posts[i-1] 
          prevYear = Time.parse(posts[i-1]['date']).strftime('%Y')
          prevMonth = Time.parse(posts[i-1]['date']).strftime('%B')
        end
        
        if(prevYear == thisYear) 
          if(prevMonth == thisMonth)
            collated.last['months'].last['posts'] << post # append to last year & month
          else
            collated.last['months'] << {
                'month' => thisMonth,
                'posts' => [post]
              } # create new month
          end
        else
          collated << { 
            'year' => thisYear,
            'months' => [{ 
              'month' => thisMonth,
              'posts' => [post]
            }]
          } # create new year & month
        end

      end

      collated
    end

    def self.parse_tags(posts)
      tags = {}
  
      posts.each do |post|
        Array(post['tags']).each do |tag|
          if tags[tag]
            tags[tag]['count'] += 1
          else
            tags[tag] = { 'count' => 1, 'name' => tag, 'posts' => [] }
          end 

          tags[tag]['posts'] << post['id']
        end
      end  
      tags
    end

    def self.parse_categories(posts)
      categories = {}

      posts.each do |post|
        cats = post['categories'] ? post['categories'] : Array(post['category']).join('/')
    
        Array(cats).each do |cat|
          cat = Array(cat).join('/')
          if categories[cat]
            categories[cat]['count'] += 1
          else
            categories[cat] = { 'count' => 1, 'name' => cat, 'posts' => [] }
          end 

          categories[cat]['posts'] << post['id']
        end
      end  
      categories
    end

  end # Post
  
  module Pages
    
    # Public: Generate the Pages dictionary.
    #
    def self.generate
      raise "Ruhoh.config cannot be nil.\n To set config call: Ruhoh.setup" unless Ruhoh.config
      puts "=> Generating Pages..."

      invalid_pages = []
      dictionary = {}
      total_pages = 0
      FileUtils.cd(Ruhoh.config.site_source_path) {
        Dir.glob("**/*.*") { |filename| 
          next if FileTest.directory?(filename)
          next if ['_', '.'].include? filename[0]
          total_pages += 1

          File.open(filename) do |page|
            front_matter = page.read.match(Ruhoh::Utils::FMregex)
            if !front_matter
              invalid_pages << filename ; next
            end

            data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
            data['id'] = filename
            data['url'] = self.permalink(data)
            data['title'] = data['title'] || self.titleize(filename)

            dictionary[filename] = data
          end
        }
      }

       open(Ruhoh.config.pages_data_path, 'w') { |page|
         page.puts dictionary.to_yaml
       }

      if invalid_pages.empty?
        puts "=> #{total_pages - invalid_pages.count }/#{total_pages} pages processed."
      else
        puts "=> Invalid pages not processed:"
        puts invalid_pages.to_yaml
      end   
      
      dictionary 
    end

    def self.titleize(filename)
      File.basename( filename, File.extname(filename) ).gsub(/[\W\_]/, ' ').gsub(/\b\w/){$&.upcase}
    end
    
    def self.permalink(page)
      url = '/' + page['id'].gsub(File.extname(page['id']), '.html')
      
      # sanitize url
      url = url.split('/').reject{ |part| part =~ /^\.+$/ }.join('/')
      url
    end
    
  end # Page
  
  module Partials
    
    def self.generate
      partials_path = './_client/partials'
      partials_manifest = JSON.parse(File.open("#{partials_path}/manifest.json").read)
      partials = {}
      FileUtils.cd(partials_path) {
        partials_manifest.each do |p|
          next unless File.exist? p['path']
          partials[p['name']] = File.open(p['path']).read
        end  
      }
      partials
    end
  end
  
  module Layouts

    # Generate layouts only from the active theme.
    def self.generate
      layouts = {}
      FileUtils.cd(File.join(Ruhoh.config.site_source_path, Ruhoh.config.theme_path, 'layouts')) {
        Dir.glob("**/*.*") { |filename|
          next if FileTest.directory?(filename)
          next if ['_','.'].include? filename[0]
          id = File.basename(filename, File.extname(filename))
          layouts[id] = Ruhoh::Utils.parse_file(Ruhoh.config.theme_path, 'layouts', filename)
        }
      }
      layouts
    end

  end
  
  class Database
    class << self
      attr_accessor :config, :routes, :posts, :pages, :layouts, :partials
    end
    
    def self.get(name)
      self.__send__ name.to_s
    end

    def self.update
      self.update_config
      self.update_routes
      self.update_posts
      self.update_pages
      self.update_layouts
      self.update_partials
    end
    
    def self.update_config
      @config = YAML.load_file( File.join(Ruhoh.config.site_source_path, '_config.yml') )
    end
    
    def self.update_routes
      @routes = Ruhoh::Routes.generate
    end
    
    def self.update_posts
      @posts = Ruhoh::Posts.generate
    end
    
    def self.update_pages
      @pages = Ruhoh::Pages.generate
    end

    def self.update_layouts
      @layouts = Ruhoh::Layouts.generate
    end
    
    def self.update_partials
      @partials = Ruhoh::Partials.generate
    end
    
    update
  end
  
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
