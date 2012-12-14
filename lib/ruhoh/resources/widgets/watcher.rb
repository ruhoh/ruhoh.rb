module Ruhoh::Resources::Widgets
  class Watcher
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collection = ruhoh.resources.load_collection("widgets")
    end
    
    def match(path)
      path =~ %r{^#{@collection.path}}
    end
    
    def update(path)
      @ruhoh.db.clear(:widgets)
    end
  end
end