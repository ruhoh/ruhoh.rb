module Ruhoh::Collections::Asset
  class CollectionView < SimpleDelegator
    attr_accessor :_cache
    include Ruhoh::Collectable

    def initialize(data, ruhoh=nil)
      @ruhoh = ruhoh
      data.each do |item|
        item.collection = self
      end
      super(data)
      @_cache = {}
    end

    def all
      each
    end

    # Load Assets as defined within the given sub_context
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
      sub_context
        .split("\n")
        .map{ |s| link = s.gsub(/\s/, ''); link.empty? ? nil : link }
        .compact
        .map { |name| generate_html(make_url(name)) }
        .join("\n")
    end

    # noop
    # Javascript and stylesheet assets should inherit this class and override this method.
    def generate_html(url)
      url
    end

    def make_url(name)
      return name if name =~ /^(http:|https:)?\/\//i
      #  TODO: This should find files regardless of their extension, e.g:
      # style and style.css
      name = "#{ collection_name }/#{ name }"
      path = if @_cache[name]
               @_cache[name]
             else
               @_cache[name] = name
               "#{name}?#{rand()}"
             end

      @ruhoh.to_url("assets", path)
    end
  end
end
