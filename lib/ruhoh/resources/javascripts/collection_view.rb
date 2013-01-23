module Ruhoh::Resources::Javascripts
  class CollectionView < Ruhoh::Resources::Base::CollectionView
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
      collection = @ruhoh.resources.load_collection("javascripts")
      javascripts = sub_context.split("\n").map{ |s| s.gsub(/\s/, '') }.delete_if(&:empty?)
      javascripts.map { |name|
        url = (name =~ /^(http:|https:)?\/\//i) ?
          name :
          (@ruhoh.to_url(collection.url_endpoint, name) + "?#{rand()}")
        
        "<script src='#{url}'></script>"
      }.join("\n")
    end
  end
end
