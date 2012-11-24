module Ruhoh::Resources::Widgets
  class Watcher
    def initialize(resource)
      @resource = resource
      @ruhoh = resource.ruhoh
    end
    
    def match(path)
      path =~ %r{^#{@resource.path}}
    end
    
    def update(path)
      ruhoh.db.clear(:widgets)
    end
  end
end