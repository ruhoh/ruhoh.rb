module Ruhoh::Resources::Data
  class Watcher
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end
  
    def match(path)
      path == "data.yml"
    end
  
    def update(path)
      @ruhoh.db.clear(:data)
    end
  end
end