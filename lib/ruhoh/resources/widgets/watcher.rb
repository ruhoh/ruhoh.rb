module Ruhoh::Resources::Widgets
  class Watcher < Ruhoh::Resources::Base::Watcher
    def match(path)
      path =~ %r{^#{@collection.namespace}}
    end

    def update(path)
      @ruhoh.db.clear(:widgets)
    end
  end
end