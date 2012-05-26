class Ruhoh
  module Parsers
    module Assets
      AssetStructure = Struct.new(:stylesheets, :scripts)

      def self.generate
        if File.exist?(Ruhoh.paths.theme_config)
          theme_config = File.open(Ruhoh.paths.theme_config, 'r:UTF-8') {|f| JSON.parse(f.read) }
        else
          theme_config = nil
        end
        
        AssetStructure.new(self.stylesheets(theme_config), self.scripts(theme_config))
      end
      
      # Collect all the stylesheets.
      # Themes explicitly define which stylesheets to load via theme.json.
      # Widget Styles:
      # All styling is managed by the theme. If the theme provides widget stylesheets
      # those stylesheets should load automatically when those widgets are enabled.
      # Additionally the theme.json may specify an explicit widget stylesheet to load.
      #
      # Returns Array of URLs to stylesheets to be included globally.
      def self.stylesheets(theme_config)
        return [] if theme_config.nil?
        stylesheets = theme_config[Ruhoh.names.stylesheets.to_s].dup
        if stylesheets.is_a? Hash
          stylesheets.each do |key, value|
            next if key == Ruhoh.names.widgets
            stylesheets[key] = Array(value).map { |v| "#{Ruhoh.urls.theme_stylesheets}/#{v}" }
          end
        end

        stylesheets[Ruhoh.names.widgets.to_s] = []
        Ruhoh::DB.widgets.each_key do |name|
          stylesheet = theme_config[Ruhoh.names.stylesheets.to_s][Ruhoh.names.widgets.to_s][name] rescue "#{name}.css"
          stylesheet ||=  "#{name}.css"
          file = File.join(Ruhoh.paths.theme_widgets, name, Ruhoh.names.stylesheets, stylesheet)
          next unless File.exists?(file)
          stylesheets[Ruhoh.names.widgets.to_s] << [Ruhoh.urls.theme_widgets, name, Ruhoh.names.stylesheets, stylesheet].join('/')
        end
        
        stylesheets
      end
      
      # Collect all the scripts.
      # Themes explicitly define which javascripts to load via theme.json.
      # Additionally, widgets may register javascript dependencies,
      # which are resolved here.
      #
      # Returns Array of URLs to javascripts to be included globally.
      def self.scripts(theme_config)
        return [] if theme_config.nil?
        scripts = theme_config[Ruhoh.names.scripts.to_s] || []
        Ruhoh::DB.widgets.each_value do |widget|
          next unless widget[Ruhoh.names.scripts.to_s]
          scripts += Array(widget[Ruhoh.names.scripts.to_s]).map! {|path| 
            [Ruhoh.urls.widgets, widget['name'], Ruhoh.names.scripts, path].join('/')
          }
        end

        scripts
      end

    end #Assets
  end #Parsers
end #Ruhoh