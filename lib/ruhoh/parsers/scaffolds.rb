class Ruhoh
  module Parsers
    class Scaffolds < Base

      def paths
        [@ruhoh.paths.system_scaffolds, @ruhoh.paths.scaffolds]
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
          FileUtils.cd(@base) {
            File.open(@id, 'r:UTF-8') { |f| dict[@id] = f.read }
          }
          dict
        end
      end
      
    end
  end
end