module Ruhoh::Resources::Theme
  class Watcher
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collection = ruhoh.resources.load_collection("theme")
    end
  
    def match(path)
      path =~ Regexp.new("^#{@collection.path}")
    end
  
    def update(path)
      @ruhoh.db.clear(:widgets)
      @ruhoh.db.clear(:layouts)
    end
  end
end