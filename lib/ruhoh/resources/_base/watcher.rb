module Ruhoh::Resources::Base
  class Watcher
    
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collection = ruhoh.resources.load_collection(resource_name)
    end

    # noop - override in inheriting class
    def match(path)
    end

    # noop - override in inheriting class
    def update(path)
    end

    def resource_name
      self.class.name.chomp("::Watcher").split("::").pop.downcase
    end

  end
end