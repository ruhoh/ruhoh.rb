class Ruhoh

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

      @content = Ruhoh::Utils.parse_file(Ruhoh.paths.site_source, id)['content']
    end
    
    # Layouts
    def process_layouts
      @sub_layout = Ruhoh::Database.get(:layouts)[@data['layout']]
      
      if @sub_layout['data']['layout']
        @master_layout = Ruhoh::Database.get(:layouts)[@sub_layout['data']['layout']]
      end
    end
    
    def render
      Ruhoh::Templater.process(self)
    end
    
    def attributes
      {
        "data" => @data,
        "content" => @content
      }
    end
    
  end #Page
  
end #Ruhoh