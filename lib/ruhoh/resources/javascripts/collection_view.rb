module Ruhoh::Resources::Javascripts
  class CollectionView < SimpleDelegator
    attr_accessor :_cache

    def initialize(collection)
      super(collection)
      @_cache = {}
    end

    # Load javascripts as defined within the given sub_context
    #
    # Example:
    #   {{# javascripts.load }}
    #     app.js
    #     scroll.js
    #   {{/ javascripts.load }}
    #   (scripts are separated by newlines)
    #
    # This is a convenience method that will automatically create script tags
    # with respect to ruhoh's internal URL generation mechanism; e.g. base_path.
    #
    # @returns[String] HTML script tags for given javascripts.
    def load(sub_context)
      javascripts = sub_context.split("\n").map{ |s| s.gsub(/\s/, '') }.delete_if(&:empty?)
      javascripts.map { |name|
        "<script src='#{make_url(name)}'></script>"
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
