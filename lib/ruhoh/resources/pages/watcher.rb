module Ruhoh::Resources::Pages
  class Watcher < Ruhoh::Base::Watcher
    def match(path)
      path =~ %r{^#{@collection.namespace}}
    end

    def update(path)
      path = path.gsub(/^.+\//, '')
      key = @ruhoh.db.routes.key(path)
      @ruhoh.db.routes.delete(key)
      @ruhoh.db.update("resource" => @collection.namespace, "id" => path)
    end
  end
end