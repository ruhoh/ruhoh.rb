module Ruhoh::Resources
  class Partials < Resource

    class Modeler < BaseModeler
      def generate
        dict = {}
        name = @pointer['id'].chomp(File.extname(@pointer['id']))
        File.open(@pointer['realpath'], 'r:UTF-8') { |f| dict[name] = f.read }
        dict
      end
    end
    
    class Watcher
      def initialize(resource)
        @resource = resource
        @ruhoh = resource.ruhoh
      end
      
      def match(path)
        path =~ %r{^(#{@resource.path}|themes\/#{@ruhoh.config['theme']['name']}\/partials)}
      end
      
      def update(path)
        ruhoh.db.clear(:partials)
      end
    end

  end
end