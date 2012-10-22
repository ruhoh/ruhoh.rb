module Ruhoh::Plugins
  class Partials < Plugin

    class Modeler < BaseModeler
      def generate
        dict = {}
        name = @pointer['id'].chomp(File.extname(@pointer['id']))
        File.open(@pointer['realpath'], 'r:UTF-8') { |f| dict[name] = f.read }
        dict
      end
    end
    
    class Watch
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
      
      def match(path)
        path =~ Regexp.new("^(partials|themes\/#{@ruhoh.config['theme']['name']}\/partials)")
      end
      
      def update(path)
        ruhoh.db.clear(:partials)
      end
    end

  end
end