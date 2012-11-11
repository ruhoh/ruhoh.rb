module Ruhoh::Resources
  class Site < Resource

    def generate
      Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.base, "site.yml") || {}
    end
    
    class Watcher
      def initialize(resource)
        @resource = resource
        @ruhoh = resource.ruhoh
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