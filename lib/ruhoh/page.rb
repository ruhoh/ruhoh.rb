class Ruhoh

  class Page
    attr_reader :id, :data, :content, :sub_layout, :master_layout
    attr_accessor :templater, :converter

    def initialize
      @templater = Ruhoh::Templaters::Base
      @converter = Ruhoh::Converter
    end
    
    # Public: Change this page using an id.
    def change(id)
      @data = nil
      @data = id =~ Regexp.new("^#{Ruhoh.folders.posts}") ? Ruhoh::DB.posts['dictionary'][id] : Ruhoh::DB.pages[id]
      raise "Page #{id} not found in database" unless @data
      @id = id
    end
    
    # Public: Change this page using a URL.
    def change_with_url(url)
      id = Ruhoh::DB.routes[url]
      raise "Page id not found for url: #{url}" unless id
      self.change(id)
    end
    
    def render
      raise "ID is null: Id must be set via page.change(id) or page.change_with_url(url)" if @id.nil?
      self.process_layouts
      self.process_content
      @templater.render(self)
    end
    
    def process_layouts
      raise "ID is null: Id must be set via page.change(id) or page.change_with_url(url)" if @id.nil?
      @sub_layout = Ruhoh::DB.layouts[@data['layout']]
      
      if @sub_layout['data']['layout']
        @master_layout = Ruhoh::DB.layouts[@sub_layout['data']['layout']]
      end
    end
    
    # We need to pre-process the content data
    # in order to invoke converters on the result.
    # Converters (markdown) always choke on the templating language.
    def process_content
      raise "ID is null: Id must be set via page.change(id) or page.change_with_url(url)" if @id.nil?
      data = Ruhoh::Utils.parse_file(Ruhoh.paths.site_source, @id)
      raise "Invalid Frontmatter in page: #{@id}" if data.empty?
      
      @content = @templater.parse(data['content'], self)
      @content = @converter.convert(self)
    end
    
    # Public: Return page attributes suitable for inclusion in the
    # 'payload' of the given templater.
    def attributes
      raise "ID is null: Id must be set via page.change(id) or page.change_with_url(url)" if @id.nil?
      @data['content'] = @content
      @data
    end
    
    # Public: Formats the path to the compiled file based on the URL.
    #
    # Returns: [String] The relative path to the compiled file for this page.
    def compiled_path
      raise "ID is null: Id must be set via page.change(id) or page.change_with_url(url)" if @id.nil?
      path = CGI.unescape(@data['url']).gsub(/^\//, '') #strip leading slash.
      path = "index.html" if path.empty?
      path += '/index.html' unless path =~ /\.html$/
      path
    end
    
  end #Page
  
end #Ruhoh