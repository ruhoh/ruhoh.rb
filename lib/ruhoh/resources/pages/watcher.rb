module Ruhoh::Resources::Pages
  class Watcher
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collection = ruhoh.resources.load_collection("pages")
    end
    
    def match(path)
      path =~ %r{^#{@collection.path}}
    end
    
    def update(path)
      path = path.gsub(/^.+\//, '')
      key = @ruhoh.db.routes.key(path)
      @ruhoh.db.routes.delete(key)
      @ruhoh.db.update("resource" => type, "id" => path)
    end
  end
end