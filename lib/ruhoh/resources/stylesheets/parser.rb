module Ruhoh::Resources::Stylesheets
  # Collect all registered stylesheets.
  # Themes explicitly define which stylesheets to load via theme.yml.
  # All styling is managed by the theme, including widget styles.
  # If the theme provides widget stylesheets they will load automatically.
  # theme.yml may also specify an explicit widget stylesheet to load.
  class Parser < Ruhoh::Resources::Resource
    
    # Get the config from theme.yml
    def config
      hash = @ruhoh.db.config("theme")["stylesheets"]
      hash.is_a?(Hash) ? hash : {}
    end
    
    # Generates mappings to all registered stylesheets.
    # Create mappings for stylesheets registered to the theme layouts.
    # Themes register stylesheets relative to their layouts.
    # Returns Hash with layout names as keys and Array of asset Objects as values.
    def generate
      return {} if config.empty?
      assets = {}
      config.each do |page, value|
        next if page == "widgets" # Widgets are handled separately.
        assets[page] = Array(value).map { |v|
          {
            "url" => url(v),
            "id" => File.join(@ruhoh.paths.theme, "stylesheets", v)
          }
        }
      end
      
      assets
    end
    
    def url_endpoint
      ["assets", @ruhoh.db.config('theme')['name'], "stylesheets"].join("/")
    end
    
    def url(node)
      return node if node =~ /^(http:|https:)?\/\//i
      @ruhoh.to_url(url_endpoint, node)
    end
    
    # Create mappings for stylesheets registered to a given widget.
    # A theme may provide widget stylesheets which will load automatically,
    # provided they adhere to the default naming rules.
    # Themes may also specify an explicit widget stylesheet to load.
    # 
    # Returns Array of asset objects.
    def widget_stylesheets
      assets = []
      @ruhoh.db.widgets.each_key do |name|
        default_name = "#{name}.css"
        stylesheet = config["widgets"][name] rescue default_name
        stylesheet ||=  default_name
        file = File.join(@ruhoh.db.config("theme")['path_widgets'], name, "stylesheets", stylesheet)
        next unless File.exists?(file)
        assets << {
          "url" => [@ruhoh.db.urls["theme_widgets"], name, "stylesheets", stylesheet].join('/'),
          "id" => file
        }
      end

      assets
    end

  end
end