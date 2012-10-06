class Ruhoh
  module Parsers
    class Layouts < Base
      
      def is_valid_page?(filepath)
        return false if FileTest.directory?(filepath)
        return false if ['_','.'].include? filepath[0]
        true
      end

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