module Ruhoh::Resources
  class Dash < Resource
    
    def url_endpoint
      "/dash"
    end
    
    class Modeler < BaseModeler
      
      def generate
        @pointer
      end
      
    end
    
    class Previewer
      def initialize(resource)
        @resource = resource
        @ruhoh = resource.ruhoh
      end

      def call(env)
        path = @ruhoh.db.dash['realpath']
        template = File.open(path, 'r:UTF-8') {|f| f.read }
        templater = Ruhoh::Templaters::Master.new(@ruhoh)
        output = templater.render(template, {"page" => ""})

        [200, {'Content-Type' => 'text/html'}, [output]]
      end
    end
    
 end
end