class Ruhoh

  module Parsers

    # Sitewide data hash + configuration file.
    module Site
      
      def self.generate
        site = File.join(Ruhoh.paths.site_source, Ruhoh.files.site)
        site = File.exist?(site) ? File.open(site).read : ''
        site = YAML.load(site) || {}
        
        config = File.join(Ruhoh.paths.site_source, Ruhoh.files.config)
        config = File.exist?(config) ? File.open(config).read : ''
        config = YAML.load(config) || {}
        
        site['config'] = config
        site
      end
    
    end #Site
  
  end #Parsers
  
end #Ruhoh