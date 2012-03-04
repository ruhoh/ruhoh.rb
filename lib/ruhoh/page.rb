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
    
    def render
      self.process_data
      self.process_layouts
      Ruhoh::Templater.process(self)
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