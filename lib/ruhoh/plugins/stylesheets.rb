module Ruhoh::Plugins
  # Collect all registered stylesheets.
  # Themes explicitly define which stylesheets to load via theme.yml.
  # All styling is managed by the theme, including widget styles.
  # If the theme provides widget stylesheets they will load automatically.
  # theme.yml may also specify an explicit widget stylesheet to load.
  class Stylesheets < Base
    
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
      theme_path = paths.select{|h| h["name"] == "theme"}.first["path"]
      assets = {}
      config.each do |page, value|
        next if page == "widgets" # Widgets are handled separately.
        assets[page] = Array(value).map { |v|
          {
            "url" => url(v),
            "id" => File.join(theme_path, "stylesheets", v)
          }
        }
      end
      
      assets
    end
    
    def url(node)
      (node =~ /^(http:|https:)?\/\//i) ? node : "#{@ruhoh.urls.theme_stylesheets}/#{node}"
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
        stylesheet = config[Ruhoh.names.widgets][name] rescue default_name
        stylesheet ||=  default_name
        file = File.join(@ruhoh.db.config("theme")['path_widgets'], name, Ruhoh.names.stylesheets, stylesheet)
        next unless File.exists?(file)
        assets << {
          "url" => [@ruhoh.urls.theme_widgets, name, Ruhoh.names.stylesheets, stylesheet].join('/'),
          "id" => file
        }
      end

      assets
    end

  end
end