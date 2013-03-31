require 'ruhoh/views/rmustache'

module Ruhoh::Views
  module Helpers ; end
  class MasterView < RMustache
    attr_reader :sub_layout, :master_layout
    attr_accessor :page_data
    
    def initialize(ruhoh, pointer_or_content)
      @ruhoh = ruhoh
      @partials = @ruhoh.resources.load_collection("partials").generate

      if pointer_or_content.is_a?(Hash)
        @page_data = @ruhoh.db.get(pointer_or_content)
        @page_data = {} unless @page_data.is_a?(Hash)

        raise "Page #{pointer_or_content['id']} not found in database" unless @page_data

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
      @page = collection ? collection.new_model_view(@page_data) : nil
    end

    def collection
      __send__(@pointer["resource"])
    end
    
    def urls
      @ruhoh.url_endpoints
    end
    
    def content
      render(@content || @ruhoh.db.content(@pointer))
    end

    def partial(name)
      p = @partials[name.to_s]
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

    def method_missing(name, *args, &block)
      # Suport for calling resource namespace
      if @ruhoh.resources.exist?(name.to_s)
        return load_collection_view_for(name.to_s)
      end

      # Suport for calling ?to_resource contextual block helpers
      resource = name.to_s.gsub(/^to_/, '')
      if @ruhoh.resources.exist?(resource)
        return resource_generator_for(resource, *args)
      end

      super
    end

    def respond_to?(method)
      # Suport for calling resource namespace
      return true if @ruhoh.resources.exist?(method.to_s)

      # Suport for calling ?to_resource contextual block helpers
      return true if @ruhoh.resources.exist?(method.to_s.gsub(/^to_/, ''))

      super
    end

    protected

    # Load collection views dynamically when calling a resources name.
    # Uses method_missing to catch calls to resource namespace.
    # @returns[CollectionView|nil] for the calling resource.
    def load_collection_view_for(resource)
      return nil unless @ruhoh.resources.collection_view?(resource)
      collection_view = @ruhoh.resources.load_collection_view(resource)
      collection_view.master = self
      collection_view
    end

    # Takes an Array or string of resource ids and generates the resource objects.
    # Uses method_missing to catch calls to 'to_<resource>` contextual helper.
    # @returns[Array] the resource model view objects or raw data hash.
    def resource_generator_for(resource, sub_context)
      collection_view = load_collection_view_for(resource)
      collection_data = collection_view.generate
      Array(sub_context).map { |id|
        data = collection_data[id] || {}
        if collection_view && collection_view.respond_to?(:new_model_view)
          collection_view.new_model_view(data)
        else
          data
        end
      }.compact
    end

    def process_layouts
      layouts = @ruhoh.resources.load_collection_view("layouts").generate
      if @page_data['layout']
        @sub_layout = layouts[@page_data['layout']]
        raise "Layout does not exist: #{@page_data['layout']}" unless @sub_layout
      elsif @page_data['layout'] != false
        # try default
        @sub_layout = layouts[@pointer["resource"]]
      end

      if @sub_layout && @sub_layout['data']['layout']
        @master_layout = layouts[@sub_layout['data']['layout']]
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
        layout = page ? '{{{ page.content }}}' : '{{{ content }}}'
      end
      
      layout
    end
  end
end