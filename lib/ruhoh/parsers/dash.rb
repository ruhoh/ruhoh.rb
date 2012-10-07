class Ruhoh
  module Parsers
    class Dash < Base
      
      class Modeler < BaseModeler
        
        def generate
          @pointer
        end
        
      end
      
      class Previewer
        def initialize(ruhoh)
          @ruhoh = ruhoh
        end

        def call(env)
          path = @ruhoh.db.dash['realpath']
          template = File.open(path, 'r:UTF-8') {|f| f.read }
          templater = Ruhoh::Templaters::RMustache.new(@ruhoh)
          output = templater.render(template, @ruhoh.db.payload)

          [200, {'Content-Type' => 'text/html'}, [output]]
        end
      end
      
   end
  end
end