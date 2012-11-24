module Ruhoh::Resources::Site
  class Watcher
    def initialize(resource)
      @resource = resource
      @ruhoh = resource.ruhoh
    end
  
    def match(path)
      path == "site.yml"
    end
  
    def update(path)
      @ruhoh.db.clear(:site)
    end
  end
end