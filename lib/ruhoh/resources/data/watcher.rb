module Ruhoh::Resources::Data
  class Watcher < Ruhoh::Base::Watcher
    def match(path)
      path == "data.yml"
    end
  
    def update(path)
      @ruhoh.db.clear(:data)
    end
  end
end