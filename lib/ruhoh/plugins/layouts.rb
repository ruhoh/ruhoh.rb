class Ruhoh
  module Plugins
    class Layouts < Base
      
      class Modeler < BaseModeler
        def generate
          dict = {}
          id = File.basename(@pointer['id'], File.extname(@pointer['id']))
          data = Ruhoh::Utils.parse_layout_file(@pointer['realpath'])
          data['id'] = id
          dict[id] = data
          dict
        end
      end

    end
  end
end