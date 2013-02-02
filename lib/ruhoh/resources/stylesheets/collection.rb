module Ruhoh::Resources::Stylesheets
  class Collection < Ruhoh::Resources::Base::Collection

    def url_endpoint
      "assets/#{namespace}"
    end

    # All styling is managed by the theme, including widget styles.
    # If the theme provides widget stylesheets they will load automatically.
    # theme.yml may also specify an explicit widget stylesheet to load.

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
        stylesheet = theme_config["widgets"][name] rescue default_name
        stylesheet ||=  default_name
        file = File.join(@ruhoh.paths.theme, "widgets", name, "stylesheets", stylesheet)
        next unless File.exists?(file)
        assets << {
          "url" => [@ruhoh.db.urls["theme"], "widgets", name, "stylesheets", stylesheet].join('/'),
          "id" => file
        }
      end

      {"widgets" => assets}
    end

  end
end