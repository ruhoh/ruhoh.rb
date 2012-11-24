module Ruhoh::Resources::Partials
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