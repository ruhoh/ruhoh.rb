class Ruhoh

  class Page
    attr_accessor :data, :content, :sub_layout, :master_layout

    # Change this page via a URL.
    def change(url)
      @id = nil
      url = '/index.html' if url == '/'
      @id = Ruhoh::DB.routes[url]
      raise "Page id not found for url: #{url}" unless @id
    end
    
    def render
      self.process_data
      self.process_layouts
      self.process_content
      Ruhoh::Templater.expand_and_render(self)
    end
    
    def process_data
      @data = @id =~ Regexp.new("^#{Ruhoh.folders.posts}") ? Ruhoh::DB.posts['dictionary'][@id] : Ruhoh::DB.pages[@id]
      raise "Page #{@id} not found in database" unless @data

      @content = Ruhoh::Utils.parse_file(Ruhoh.paths.site_source, @id)['content']
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
      @content = Ruhoh::Templater.render(@content, self)
      @content = Ruhoh::Converter.convert(self)
    end
    
    # This is the callback for when Ruhoh::DB changes, but we may not need it.
    def update(name)
      puts "page update callback: #{name}"
      case name
      when :layouts
        self.process_layouts
      when :posts || :pages
        self.process_data
      end
    end
    
    def attributes
      @data['content'] = @content
      @data
    end
    
  end #Page
  
end #Ruhoh