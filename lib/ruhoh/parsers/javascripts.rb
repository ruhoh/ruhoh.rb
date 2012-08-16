class Ruhoh
  module Parsers
    # Collect all the javascripts.
    # Themes explicitly define which javascripts to load via theme.yml.
    # Additionally, widgets may register javascript dependencies, which are resolved here.
    module Javascripts

      # Generates mappings to all registered javascripts.
      # Returns Hash with layout names as keys and Array of asset Objects as values
      def self.generate
        assets = self.theme_javascripts
        assets[Ruhoh.names.widgets] = self.widget_javascripts
        assets
      end

      def self.theme_javascripts
        return {} unless Ruhoh::DB.theme_config[Ruhoh.names.javascripts].is_a? Hash
        assets = {}
        Ruhoh::DB.theme_config[Ruhoh.names.javascripts].each do |key, value|
          next if key == Ruhoh.names.widgets # Widgets are handled separately.
          assets[key] = Array(value).map { |v|
            url = (v =~ /^(http:|https:)?\/\//i) ? v : "#{Ruhoh.urls.theme_javascripts}/#{v}"
            {
              "url" => url,
              "id" => File.join(Ruhoh.paths.theme_javascripts, v)
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
      def self.widget_javascripts
        assets = []
        Ruhoh::DB.widgets.each_value do |widget|
          next unless widget[Ruhoh.names.javascripts]
          assets += Array(widget[Ruhoh.names.javascripts]).map {|path|
            {
              "url" => [Ruhoh.urls.widgets, widget['name'], Ruhoh.names.javascripts, path].join('/'),
              "id"  => File.join(Ruhoh.paths.widgets, widget['name'], Ruhoh.names.javascripts, path)
            }
          }
        end
        
        assets
      end
      
    end #Javascripts
  end #Parsers
end #Ruhoh