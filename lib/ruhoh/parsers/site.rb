class Ruhoh

  module Parsers

    # Sitewide data hash + configuration file.
    module Site
      
      def self.generate
        site = Ruhoh::Utils.parse_yaml_file(Ruhoh.paths.site_data) || {}
        config = Ruhoh::Utils.parse_yaml_file(Ruhoh.paths.config_data)
        site['config'] = config
        site
      end
    
    end #Site
  
  end #Parsers
  
end #Ruhoh