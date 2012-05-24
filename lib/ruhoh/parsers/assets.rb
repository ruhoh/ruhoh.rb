class Ruhoh
  module Parsers
    module Assets

      def self.generate
        theme_config = self.theme_config
        {
          'stylesheets' => self.stylesheets(theme_config),
          'scripts' => self.scripts(theme_config)
        }
      end
      
      # Get the theme config file.
      #
      # Returns Hash of configuration parameters
      def self.theme_config
        config_file = File.join(Ruhoh.paths.theme.name, 'theme.json')

        if File.exist?(config_file)
          File.open(config_file, 'r:UTF-8') {|f| JSON.parse(f.read) }
        else
          { "stylesheets" => [], "scripts" => [] }
        end
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
        stylesheets = theme_config['stylesheets'].dup
        if stylesheets.is_a? Hash
          stylesheets.each do |key, value|
            next if key == "widgets"
            stylesheets[key] = Array(value).map { |v| "#{Ruhoh.config.assets.stylesheets}/#{v}" }
          end
        end

        stylesheets['widgets'] = []
        Ruhoh::DB.widgets.each_key do |name|
          stylesheet = theme_config['stylesheets']['widgets'][name] rescue "#{name}.css"
          stylesheet ||=  "#{name}.css"
          file = File.join(Ruhoh.paths.theme.widgets, name, "stylesheets", stylesheet)
          next unless File.exists?(file)
          stylesheets['widgets'] << "#{Ruhoh.config.assets.widgets}/#{name}/stylesheets/#{stylesheet}"
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
        scripts = theme_config['scripts'] || []
        Ruhoh::DB.widgets.each_value do |h|
          scripts += Array(h["scripts"]).map! {|path| 
            "/assets/widgets/#{h['name']}/scripts/#{path}"
          } if h["scripts"]
        end

        scripts
      end

    end #Assets
  end #Parsers
end #Ruhoh