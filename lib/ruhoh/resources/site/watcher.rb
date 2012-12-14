module Ruhoh::Resources::Site
  class Watcher
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end
  
    def match(path)
      path == "site.yml"
    end
  
    def update(path)
      @ruhoh.db.clear(:site)
    end
  end
end