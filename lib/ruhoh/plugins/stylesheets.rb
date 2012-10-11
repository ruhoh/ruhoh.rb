module Ruhoh::Plugins
  # Collect all registered stylesheets.
  # Themes explicitly define which stylesheets to load via theme.yml.
  # All styling is managed by the theme, including widget styles.
  # If the theme provides widget stylesheets they will load automatically.
  # theme.yml may also specify an explicit widget stylesheet to load.
  class Stylesheets < Base

    # Generates mappings to all registered stylesheets.
    # Returns Hash with layout names as keys and Array of asset Objects as values
    def generate
      assets = self.theme_stylesheets
      assets[Ruhoh.names.widgets] = self.widget_stylesheets
      assets
    end
    
    # Get the config from theme.yml
    def config
      hash = @ruhoh.db.config("theme")["stylesheets"]
      hash.is_a?(Hash) ? hash : {}
    end
    
    # Create mappings for stylesheets registered to the theme layouts.
    # Themes register stylesheets relative to their layouts.
    # Returns Hash with layout names as keys and Array of asset Objects as values.
    def theme_stylesheets
      return {} unless @ruhoh.db.config("theme")[Ruhoh.names.stylesheets].is_a? Hash
      assets = {}
      config.each do |key, value|
        next if key == Ruhoh.names.widgets # Widgets are handled separately.
        assets[key] = Array(value).map { |v|
          url = (v =~ /^(http:|https:)?\/\//i) ? v : "#{@ruhoh.urls.theme_stylesheets}/#{v}"
          {
            "url" => url,
            "id" => File.join(@ruhoh.db.config("theme")['path_stylesheets'], v)
          }
        }
      end
      
      assets
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