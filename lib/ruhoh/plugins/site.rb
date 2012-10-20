module Ruhoh::Plugins
  class Site < Base

    def generate
      Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.base, "site.yml") || {}
    end
    
    class Watch
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
      
      def match(path)
        path == "site.yml"
      end
      
      def update(path)
        @ruhoh.db.clear(:site)
      end
    end

  end
end