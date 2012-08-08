class Ruhoh
  module Parsers
    module ThemeConfig
      
      def self.generate
        config = Ruhoh::Utils.parse_yaml_file(Ruhoh.paths.theme_config_data)
        if config.nil?
          Ruhoh::Friend.say{ 
            yellow "WARNING: theme.yml config file not found:"
            yellow "  #{Ruhoh.paths.theme_config_data}"
          }
          return {}
        end
        return {} unless config.is_a? Hash
        
        config
      end
      
    end #ThemeConfig
  end #Parsers
end #Ruhoh