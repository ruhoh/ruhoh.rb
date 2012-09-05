class Ruhoh
  class Page
    attr_reader :id, :data, :sub_layout, :master_layout
    attr_accessor :templater

    def initialize(id)
      @id = id
      @path = id
      @data = if id =~ Regexp.new("^#{Ruhoh.names.posts}")
        Ruhoh::DB.posts['dictionary'][id] 
      else
        @path = "#{Ruhoh.names.pages}/#{id}"
        Ruhoh::DB.pages[id]
      end
      raise "Page #{id} not found in database" unless @data
      @templater = Ruhoh::Templaters::RMustache
    end
    
    def render
      self.process_layouts
      @templater.render(self.expand_layouts, self.payload)
    end
    
    def render_content
      self.ensure_id
      @templater.render('{{{content}}}', self.payload)
    end
    
    def process_layouts
      if @data['layout']
        @sub_layout = Ruhoh::DB.layouts[@data['layout']]
        raise "Layout does not exist: #{@data['layout']}" unless @sub_layout
      end
    
      if @sub_layout && @sub_layout['data']['layout']
        @master_layout = Ruhoh::DB.layouts[@sub_layout['data']['layout']]
        raise "Layout does not exist: #{@sub_layout['data']['layout']}" unless @master_layout
      end
      
      @data['sub_layout'] = @sub_layout['id'] rescue nil
      @data['master_layout'] = @master_layout['id'] rescue nil
      @data
    end
    
    # Expand the layout(s).
    # Pages may have a single master_layout, a master_layout + sub_layout, or no layout.
    def expand_layouts
      if @sub_layout
        layout = @sub_layout['content']

        # If a master_layout is found we need to process the sub_layout
        # into the master_layout using mustache.
        if @master_layout && @master_layout['content']
          payload = self.payload
          payload['content'] = layout
          layout = @templater.render(@master_layout['content'], payload)
        end
      else
        # Minimum layout if no layout defined.
        layout = '{{{content}}}' 
      end
      
      layout
    end
    
    def payload
      payload = Ruhoh::DB.payload.dup
      payload['page'] = @data
      payload
    end
    
    # Provide access to the page content.
    def content
      Ruhoh::Utils.parse_page_file(Ruhoh.paths.base, @path)['content']
    end
    
    # Public: Formats the path to the compiled file based on the URL.
    #
    # Returns: [String] The relative path to the compiled file for this page.
    def compiled_path
      path = CGI.unescape(@data['url']).gsub(/^\//, '') #strip leading slash.
      path = "index.html" if path.empty?
      path += '/index.html' unless path =~ /\.\w+$/
      path
    end
    
  end #Page
end #Ruhoh
