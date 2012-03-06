class Ruhoh

  class Page
    attr_reader :data, :content, :sub_layout, :master_layout

    # Public: Change this page using an id.
    def change(id)
      @data = nil
      @data = id =~ Regexp.new("^#{Ruhoh.folders.posts}") ? Ruhoh::DB.posts['dictionary'][id] : Ruhoh::DB.pages[id]
      raise "Page #{id} not found in database" unless @data
      @id = id
    end
    
    # Public: Change this page using a URL.
    def change_with_url(url)
      url = '/index.html' if url == '/'
      id = Ruhoh::DB.routes[url]
      raise "Page id not found for url: #{url}" unless id
      self.change(id)
    end
    
    def render
      self.process_layouts
      self.process_content
      Ruhoh::Templater.expand_and_render(self)
    end
    
    def process_layouts
      @sub_layout = Ruhoh::DB.layouts[@data['layout']]
      
      if @sub_layout['data']['layout']
        @master_layout = Ruhoh::DB.layouts[@sub_layout['data']['layout']]
      end
    end
    
    # We need to pre-process the content data
    # in order to invoke converters on the result.
    # Converters (markdown) always choke on the templating language.
    def process_content
      @content = Ruhoh::Utils.parse_file(Ruhoh.paths.site_source, @id)['content']
      @content = Ruhoh::Templater.render(@content, self)
      @content = Ruhoh::Converter.convert(self)
    end
    
    # Public: Return page attributes suitable for inclusion in the
    # 'payload' of the given templater.
    def attributes
      @data['content'] = @content
      @data
    end
    
    # Public: Formats the path to the compiled file based on the URL.
    #
    # Returns: [String] The relative path to the compiled file for this page.
    def compiled_path
      path = CGI.unescape(@data['url']).gsub(/^\//, '') #strip leading slash.
      path += '/index.html' unless path =~ /\.html$/
      path
    end
    
  end #Page
  
end #Ruhoh