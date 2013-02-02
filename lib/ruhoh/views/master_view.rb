require 'ruhoh/views/rmustache'

module Ruhoh::Views
  class MasterView < RMustache
    attr_reader :sub_layout, :master_layout
    attr_accessor :page_data
    
    def initialize(ruhoh, pointer_or_content)
      @ruhoh = ruhoh
      if pointer_or_content.is_a?(Hash)
        @page_data = @ruhoh.db.get(pointer_or_content)
        @page_data = {} unless @page_data.is_a?(Hash)

        raise "Page #{pointer_or_content['id']} not found in database" unless @page_data

        context.push(@page_data)
        @pointer = pointer_or_content
      else
        @content = pointer_or_content
        @page_data = {}
      end
    end
    
    def render_full
      process_layouts
      render(expand_layouts)
    end

    def render_content
      render('{{{page.content}}}')
    end

    # Delegate #page to the kind of resource this view is modeling.
    def page
      return @page if @page
      collection = __send__(@pointer["resource"])
      @page = collection ? collection.new_model_view(@page_data) : nil
    end

    def urls
      @ruhoh.db.urls
    end
    
    def content
      render(@content || @ruhoh.db.content(@pointer))
    end

    def partial(name)
      p = @ruhoh.db.partials[name.to_s]
      Ruhoh::Friend.say { yellow "partial not found: '#{name}'" } if p.nil?
      p.to_s + "\n" # newline ensures proper markdown rendering.
    end

    def to_json(sub_context)
      sub_context.to_json
    end
  
    def to_pretty_json(sub_context)
      JSON.pretty_generate(sub_context)
    end
    
    def debug(sub_context)
      Ruhoh::Friend.say { 
        yellow "?debug:"
        magenta sub_context.class
        cyan sub_context.inspect
      }

      "<pre>#{sub_context.class}\n#{sub_context.pretty_inspect}</pre>"
    end

    def raw_code(sub_context)
      code = sub_context.gsub('{', '&#123;').gsub('}', '&#125;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('_', "&#95;")
      "<pre><code>#{code}</code></pre>\n"
    end
    
    # My Post Title ===> my-post-title
    # Handy for transforming ids into css-classes in your views.
    # @returns[String]
    def to_slug(sub_context)
      Ruhoh::Utils.to_slug(sub_context)
    end
    
    # Public: Formats the path to the compiled file based on the URL.
    #
    # Returns: [String] The relative path to the compiled file for this page.
    def compiled_path
      path = CGI.unescape(@page_data['url']).gsub(/^\//, '') #strip leading slash.
      path = "index.html" if path.empty?
      path += '/index.html' unless path =~ /\.\w+$/
      path
    end
    
    protected
    
    def process_layouts
      if @page_data['layout']
        @sub_layout = @ruhoh.db.layouts[@page_data['layout']]
        raise "Layout does not exist: #{@page_data['layout']}" unless @sub_layout
      elsif @page_data['layout'] != false
        # try default
        @sub_layout = @ruhoh.db.layouts[@pointer["resource"]]
      end

      if @sub_layout && @sub_layout['data']['layout']
        @master_layout = @ruhoh.db.layouts[@sub_layout['data']['layout']]
        raise "Layout does not exist: #{@sub_layout['data']['layout']}" unless @master_layout
      end
      
      @page_data['sub_layout'] = @sub_layout['id'] rescue nil
      @page_data['master_layout'] = @master_layout['id'] rescue nil
      @page_data
    end
    
    # Expand the layout(s).
    # Pages may have a single master_layout, a master_layout + sub_layout, or no layout.
    def expand_layouts
      if @sub_layout
        layout = @sub_layout['content']

        # If a master_layout is found we need to process the sub_layout
        # into the master_layout using mustache.
        if @master_layout && @master_layout['content']
          layout = render(@master_layout['content'], {"content" => layout})
        end
      else
        # Minimum layout if no layout defined.
        layout = '{{{content}}}' 
      end
      
      layout
    end
  end
end