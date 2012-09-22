class Ruhoh
  module Parsers
    class Partials < Base

      def paths
        [@ruhoh.paths.system_partials, @ruhoh.paths.partials, @ruhoh.paths.theme_partials]
      end

      def glob
        "**/*"
      end
      
      def is_valid_page?(filepath)
        return false if FileTest.directory?(filepath)
        return false if ['.'].include? filepath[0]
        true
      end
    
      class Modeler < BaseModeler
        def generate
          dict = {}
          name = @id.chomp(File.extname(@id))
          FileUtils.cd(@base) {
            File.open(@id, 'r:UTF-8') { |f| dict[name] = f.read }
          }
          dict
        end
      end
      
    end
  end
end