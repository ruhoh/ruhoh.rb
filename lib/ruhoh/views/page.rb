module Ruhoh::Views
  class Page < Master
    attr_reader :sub_layout, :master_layout
    attr_accessor :data

    def initialize(ruhoh, pointer_or_content)
      @ruhoh = ruhoh
      if pointer_or_content.is_a?(Hash)
        @data = @ruhoh.db.get(pointer_or_content)
        raise "Page #{pointer['id']} not found in database" unless @data
        @pointer = pointer_or_content
      else
        @content = pointer_or_content
        @data = {}
      end
    end
    
    def render_full
      self.process_layouts
      render(self.expand_layouts, @data)
    end
    
    def render_content
      self.ensure_id
      @templater.render('{{{content}}}', self.payload)
    end
    
    def process_layouts
      if @data['layout']
        @sub_layout = @ruhoh.db.layouts[@data['layout']]
        raise "Layout does not exist: #{@data['layout']}" unless @sub_layout
      end
    
      if @sub_layout && @sub_layout['data']['layout']
        @master_layout = @ruhoh.db.layouts[@sub_layout['data']['layout']]
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
          payload = @data.dup
          payload['content'] = layout
          layout = render(@master_layout['content'], payload)
        end
      else
        # Minimum layout if no layout defined.
        layout = '{{{content}}}' 
      end
      
      layout
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
