module Ruhoh::Resources::Theme
  class Watcher
    include Ruhoh::Base::Watchable

    def update(path)
      @ruhoh.cache.clear(:widgets)
      @ruhoh.cache.clear(:layouts)
    end
  end
end