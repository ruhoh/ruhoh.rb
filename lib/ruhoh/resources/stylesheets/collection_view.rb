module Ruhoh::Resources::Stylesheets
  class CollectionView < SimpleDelegator
    attr_accessor :_cache

    def initialize(collection)
      super(collection)
      @_cache = {}
    end
    
    # Load Stylesheets as defined within the given sub_context
    #
    # Example:
    #   {{# stylesheets.load }}
    #     global.css
    #     custom.css
    #   {{/ stylesheets.load }}
    #   (stylesheets are separated by newlines)
    #
    # This is a convenience method that will automatically create link tags
    # with respect to ruhoh's internal URL generation mechanism; e.g. base_path
    #
    # @returns[String] HTML link tags for given stylesheets
    def load(sub_context)
      stylesheets = sub_context.split("\n").map{ |s| s.gsub(/\s/, '') }.delete_if(&:empty?)
      stylesheets.map { |name|
        "<link href='#{make_url(name)}' type='text/css' rel='stylesheet' media='all'>"
      }.join("\n")
    end

    protected

    def make_url(name)
      return name if name =~ /^(http:|https:)?\/\//i

      path = if @_cache[name]
        @_cache[name]
      else
        @_cache[name] = name
        "#{name}?#{rand()}"
      end

      ruhoh.to_url(url_endpoint, path)
    end
  end
end
