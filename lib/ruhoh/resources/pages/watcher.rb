module Ruhoh::Resources::Pages
  class Watcher
    include Ruhoh::Base::Watchable

    def update(path)
      path = path.gsub(/^.+\//, '')
      @ruhoh.routes.delete(path)
    end
  end
end