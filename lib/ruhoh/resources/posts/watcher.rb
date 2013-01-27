module Ruhoh::Resources::Posts
  class Watcher < Ruhoh::Resources::Base::Watcher
    def match(path)
      path =~ %r{^#{@collection.path}}
    end

    def update(path)
      path = path.gsub(/^.+\//, '')
      key = @ruhoh.db.routes.key(path)
      @ruhoh.db.routes.delete(key)
      @ruhoh.db.update("resource" => "posts", "id" => path)
    end
  end
end  