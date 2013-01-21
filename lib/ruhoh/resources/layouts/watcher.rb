module Ruhoh::Resources::Layouts
  class Watcher
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collection = ruhoh.resources.load_collection("layouts")
    end
  
    def match(path)
      path =~ Regexp.new("^#{@collection.path}")
    end
  
    def update(path)
      @ruhoh.db.clear(:layouts)
    end
  end
end