class Ruhoh

  module Parsers

    # Sitewide data hash + configuration file.
    module Site
      
      def self.generate
        site = Ruhoh::Utils.parse_file_as_yaml(Ruhoh.paths.site_data) || {}
        config = Ruhoh::Utils.parse_file_as_yaml(Ruhoh.paths.config_data)
        site['config'] = config
        site
      end
    
    end #Site
  
  end #Parsers
  
end #Ruhoh