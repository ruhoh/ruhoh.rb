class Ruhoh

  module Parsers

    # Sitewide data hash + configuration file.
    module Site
      @ruhoh = "meep"
      def self.generate(ruhoh)
        @ruhoh = ruhoh
        site = Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.site_data) || {}
        config = Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.config_data)
        site['config'] = config
        site
      end
    
    end #Site
  
  end #Parsers
  
end #Ruhoh