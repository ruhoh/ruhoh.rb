module Ruhoh::Resources::Widgets
  class Watcher < Ruhoh::Base::Watcher
    def match(path)
      path =~ %r{^#{@collection.namespace}}
    end

    def update(path)
      @ruhoh.cache.clear(:widgets)
    end
  end
end