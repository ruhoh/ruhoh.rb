module Ruhoh::Resources::Pages
  class Watcher < Ruhoh::Base::Watcher
    def match(path)
      path =~ %r{^#{@collection.namespace}}
    end

    def update(path)
      path = path.gsub(/^.+\//, '')
      @ruhoh.routes.delete(path)
    end
  end
end