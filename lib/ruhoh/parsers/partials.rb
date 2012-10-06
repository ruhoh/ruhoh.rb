class Ruhoh
  module Parsers
    class Partials < Base

      def is_valid_page?(filepath)
        return false if FileTest.directory?(filepath)
        return false if ['.'].include? filepath[0]
        true
      end
    
      class Modeler < BaseModeler
        def generate
          dict = {}
          name = @pointer['id'].chomp(File.extname(@pointer['id']))
          File.open(@pointer['realpath'], 'r:UTF-8') { |f| dict[name] = f.read }
          dict
        end
      end
      
    end
  end
end