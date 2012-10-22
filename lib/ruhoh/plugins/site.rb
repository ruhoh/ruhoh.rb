module Ruhoh::Plugins
  class Site < Plugin

    def generate
      Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.base, "site.yml") || {}
    end
    
    class Watcher
      def initialize(plugin)
        @plugin = plugin
        @ruhoh = plugin.ruhoh
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