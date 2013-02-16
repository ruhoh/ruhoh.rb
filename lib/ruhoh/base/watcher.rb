module Ruhoh::Base
  class Watcher
    
    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
    end

    # noop - override in inheriting class
    def match(path)
    end

    # noop - override in inheriting class
    def update(path)
    end

    def resource_name
      @collection.resource_name
    end

  end
end