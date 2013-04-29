module Ruhoh::Resources::Pages
  class Watcher
    include Ruhoh::Base::Watchable

    def update(path)
      path = path.gsub(/^.+\//, '')
      collection.routes_delete(path)
    end
  end
end