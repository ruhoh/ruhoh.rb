module Ruhoh::Resources::Stylesheets
  class CollectionView < Ruhoh::Resources::Base::CollectionView
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
      collection = @ruhoh.resources.load_collection("stylesheets")
      stylesheets = sub_context.split("\n").map{ |s| s.gsub(/\s/, '') }.delete_if(&:empty?)
      stylesheets.map { |name|
        url = (name =~ /^(http:|https:)?\/\//i) ?
          name :
          (@ruhoh.to_url(collection.url_endpoint, name) + "?#{rand()}")
        
        "<link href='#{url}' type='text/css' rel='stylesheet' media='all'>"
      }.join("\n")
    end
  end
end
