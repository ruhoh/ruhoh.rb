module Ruhoh::Plugins
  class Dash < Plugin
    
    def url_endpoint
      "/dash"
    end
    
    class Modeler < BaseModeler
      
      def generate
        @pointer
      end
      
    end
    
    class Previewer
      def initialize(plugin)
        @plugin = plugin
        @ruhoh = plugin.ruhoh
      end

      def call(env)
        path = @ruhoh.db.dash['realpath']
        template = File.open(path, 'r:UTF-8') {|f| f.read }
        templater = Ruhoh::Templaters::RMustache.new(@ruhoh)
        output = templater.render(template, {"page" => ""})

        [200, {'Content-Type' => 'text/html'}, [output]]
      end
    end
    
 end
end