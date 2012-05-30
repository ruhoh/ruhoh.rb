class Ruhoh
  module Parsers
    # Collect all the scripts.
    # Themes explicitly define which javascripts to load via theme.json.
    # Additionally, widgets may register javascript dependencies, which are resolved here.
    module Scripts

      # Generates mappings to all registered javascripts.
      # Returns Hash with layout names as keys and Array of asset Objects as values
      def self.generate
        theme_config = self.theme_config
        assets = self.theme_scripts(theme_config)
        assets[Ruhoh.names.widgets] = self.widget_scripts(theme_config)
        assets
      end

      def self.theme_scripts(theme_config)
        return {} unless theme_config[Ruhoh.names.scripts].is_a? Hash
        assets = {}
        theme_config[Ruhoh.names.scripts].each do |key, value|
          next if key == Ruhoh.names.widgets # Widgets are handled separately.
          assets[key] = Array(value).map { |v|
            {
              "url" => "#{Ruhoh.urls.theme_scripts}/#{v}",
              "id" => File.join(Ruhoh.paths.theme_scripts, v)
            }
          }
        end
        
        assets
      end
      
      # Notes:
      #   The automatic script inclusion is currently handled within the widget parser.
      #   This differs from the auto-stylesheet inclusion relative to themes, 
      #   which is handled in the stylesheet parser.
      #   Make sure there are some standards with this.
      def self.widget_scripts(theme_config)
        assets = []
        Ruhoh::DB.widgets.each_value do |widget|
          next unless widget[Ruhoh.names.scripts]
          assets += Array(widget[Ruhoh.names.scripts]).map {|path|
            {
              "url" => [Ruhoh.urls.widgets, widget['name'], Ruhoh.names.scripts, path].join('/'),
              "id"  => File.join(Ruhoh.paths.widgets, widget['name'], Ruhoh.names.scripts, path)
            }
          }
        end
        
        assets
      end
      
      def self.theme_config
        theme_config = Ruhoh::Utils.parse_yaml_file(Ruhoh.paths.theme_config_data)
        if theme_config.nil?
          Ruhoh::Friend.say{ 
            yellow "WARNING: theme.yml config file not found:"
            yellow "  #{Ruhoh.paths.theme_config_data}"
          }
          return {}
        end
        return {} unless theme_config.is_a? Hash
        theme_config
      end
    end #Scripts
  end #Parsers
end #Ruhoh