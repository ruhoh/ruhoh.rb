module Ruhoh::Plugins
  class Partials < Base

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