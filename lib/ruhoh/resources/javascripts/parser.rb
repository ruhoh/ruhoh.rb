module Ruhoh::Resources::Javascripts
  # Collect all the javascripts.
  # Themes explicitly define which javascripts to load via theme.yml.
  # Additionally, widgets may register javascript dependencies, which are resolved here.
  class Parser < Ruhoh::Resources::Core::Base::Parser

    def config
      hash = @ruhoh.db.config("theme")["javascripts"]
      hash.is_a?(Hash) ? hash : {}
    end
    
    # Generates mappings to all registered javascripts.
    # Returns Hash with layout names as keys and Array of asset Objects as values
    def generate
      return {} if config.empty?
      assets = {}
      config.each do |key, value|
        next if key == "widgets" # Widgets are handled separately.
        assets[key] = Array(value).map { |v|
          {
            "url" => url(v),
            "id" => File.join(@ruhoh.paths.theme, "javascripts", v)
          }
        }
      end
      
      assets
    end

    def url_endpoint
      ["assets", @ruhoh.db.config('theme')['name'], "javascripts"].join("/")
    end
    
    def url(node)
      return node if node =~ /^(http:|https:)?\/\//i
      @ruhoh.to_url(url_endpoint, node)
    end

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