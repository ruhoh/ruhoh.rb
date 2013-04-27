module Ruhoh::Base
  module Watchable
    def self.included(klass)
      klass.__send__(:attr_accessor, :collection, :ruhoh)
    end

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
    end

    def match(path)
      path =~ %r{^#{ collection.namespace }}
    end

    def update(path)
      collection.ruhoh.cache.clear(collection.resource_name)
    end
  end

  # Base watcher class that loads if no custom Watcher class is defined.
  class Watcher
    include Watchable
  end
end