module Ruhoh::Base::Pages
  class Watcher < Ruhoh::Base::Watcher
    def match(path)
      path =~ %r{^#{@collection.namespace}}
    end

    def update(path)
      path = path.gsub(/^.+\//, '')
      @ruhoh.routes.delete(path)
      @ruhoh.db.update("resource" => @collection.namespace, "id" => path)
    end
  end
end