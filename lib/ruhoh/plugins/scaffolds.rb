class Ruhoh
  module Plugins
    class Scaffolds < Base
      
      class Modeler < BaseModeler
        
        def generate
          dict = {}
          File.open(@pointer['realpath'], 'r:UTF-8') { |f| dict[@pointer['id']] = f.read }
          dict
        end
      end
      
    end
  end
end