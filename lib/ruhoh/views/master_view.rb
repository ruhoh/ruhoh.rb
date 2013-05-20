require 'ruhoh/views/rmustache'

module Ruhoh::Views
  module Helpers ; end
  class MasterView < RMustache
    attr_reader :sub_layout, :master_layout
    attr_accessor :page_data
    
    def initialize(ruhoh, pointer_or_data)
      @ruhoh = ruhoh
      define_resource_collection_namespaces(ruhoh)

      if pointer_or_data['id']
        @pointer = pointer_or_data
        @page = collection.find(pointer_or_data)
        unless @page
          raise "Could not find the page with pointer: #{ pointer_or_data }" +
            "Finding this page is required because an 'id' key is being passed."
        end

        @page_data = @page.data.dup # legacy...working on removing this..
      else
        @content = pointer_or_data['content']
        @page_data = pointer_or_data
        @pointer = pointer_or_data
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
      collection ? collection.find(@pointer) : nil
    end

    def collection
      @pointer["resource"] ? __send__(@pointer["resource"]) : nil
    end

    def urls
      @ruhoh.collections.url_endpoints
    end

    def content
      render(@content || page.content)
    end

    # NOTE: newline ensures proper markdown rendering.
    def partial(name)
      partial = partials.find(name.to_s)
      partial ?
        partial.process.to_s + "\n" :
        Ruhoh::Friend.say { yellow "partial not found: '#{name}'" } 
    end

    def page_collections
      @ruhoh.collections.acting_as_pages.map do |a|
        @ruhoh.collection(a)
      end
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
        @sub_layout = layouts.find(@page_data['layout'], :all => true)
        raise "Layout does not exist: #{@page_data['layout']}" unless @sub_layout
      elsif @page_data['layout'] != false
        # try default
        @sub_layout = layouts.find(@pointer["resource"], :all => true)
      end

      if @sub_layout && @sub_layout.layout
        @master_layout = layouts.find(@sub_layout.layout)
        raise "Layout does not exist: #{ @sub_layout.layout }" unless @master_layout
      end
    end

    # Expand the layout(s).
    # Pages may have a single master_layout, a master_layout + sub_layout, or no layout.
    def expand_layouts
      if @sub_layout
        layout = @sub_layout.content

        # If a master_layout is found we need to process the sub_layout
        # into the master_layout using mustache.
        if @master_layout && @master_layout.content
          layout = render(@master_layout.content, {"content" => layout})
        end
      else
        # Minimum layout if no layout defined.
        layout = page ? '{{{ page.content }}}' : '{{{ content }}}'
      end

      layout
    end

    private

    # Dynamically add method proxies to resource collections
    # This is how collections are accessed throughout mustache's global context.
    # Also support calling ?to_<resource> contextual block helpers
    def define_resource_collection_namespaces(ruhoh)
      ruhoh.collections.all.each do |method_name|
        (class << self; self; end).class_eval do
          define_method(method_name) do
            load_collection_view_for(method_name.to_s)
          end

          define_method("to_#{method_name}") do |*args|
            resource_generator_for(method_name, *args)
          end
        end
      end
    end

    # Load collection views dynamically when calling a resources name.
    # Uses method_missing to catch calls to resource namespace.
    # @returns[CollectionView] for the calling resource.
    def load_collection_view_for(resource)
      view = @ruhoh.collection(resource)
      view.master = self
      view
    end

    # Transforms an Array or String of resource ids into their corresponding resource objects.
    # Uses method_missing to catch calls to 'to_<resource>` contextual helper.
    # @returns[Array] the resource modelView objects or raw data hash.
    def resource_generator_for(resource, sub_context)
      collection_view = load_collection_view_for(resource)
      Array(sub_context).map { |id|
        collection_view.find(id)
      }.compact
    end
  end
end