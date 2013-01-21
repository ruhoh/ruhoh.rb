module Ruhoh::Resources::Partials
  class Watcher
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collection = ruhoh.resources.load_collection("partials")
    end
    
    def match(path)
      path =~ %r{^(#{@collection.path}|#{@ruhoh.config['theme']['name']}\/partials)}
    end
    
    def update(path)
      @ruhoh.db.clear(:partials)
    end
  end
end