module Ruhoh::Resources::Posts
  class Watcher
    def initialize(resource)
      @resource = resource
      @ruhoh = resource.ruhoh
    end
    
    def match(path)
      path =~ %r{^#{@resource.path}}
    end
    
    def update(path)
      path = path.gsub(/^.+\//, '')
      key = @ruhoh.db.routes.key(path)
      @ruhoh.db.routes.delete(key)
      @ruhoh.db.update("resource" => type, "id" => path)
    end
  end
end  