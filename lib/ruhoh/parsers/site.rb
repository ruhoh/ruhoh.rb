class Ruhoh

  module Parsers

    # Sitewide data hash + configuration file.
    module Site
      
      def self.generate
        site = Ruhoh::Utils.parse_file_as_yaml(Ruhoh.paths.site) || {}
        config = Ruhoh::Utils.parse_file_as_yaml(Ruhoh.paths.config)
        site['config'] = config
        site
      end
    
    end #Site
  
  end #Parsers
  
end #Ruhoh