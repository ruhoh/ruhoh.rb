module Ruhoh::Resources::Javascripts
  class Collection < Ruhoh::Resources::Base::Collection

    def url_endpoint
      "assets/#{namespace}"
    end

    # widgets may register javascript dependencies, which are resolved here.
    # Notes:
    #   The automatic script inclusion is currently handled within the widget resource.
    #   This differs from the auto-stylesheet inclusion relative to themes, 
    #   which is handled in the stylesheet resource.
    #   Make sure there are some standards with this.
    def widget_javascripts
      assets = []
      @ruhoh.db.widgets.each_value do |widget|
        next unless widget["javascripts"]
        assets += Array(widget["javascripts"]).map {|path|
          {
            "url" => [@ruhoh.db.urls["widgets"], widget['name'], "javascripts", path].join('/'),
            "id"  => File.join(@ruhoh.paths.widgets, widget['name'], "javascripts", path)
          }
        }
      end
      
      assets
    end
    
  end
end