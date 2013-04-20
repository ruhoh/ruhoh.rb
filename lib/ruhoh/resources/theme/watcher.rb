module Ruhoh::Resources::Theme
  class Watcher < Ruhoh::Base::Watcher
    def match(path)
      path =~ Regexp.new("^#{@collection.namespace}")
    end

    def update(path)
      @ruhoh.cache.clear(:widgets)
      @ruhoh.cache.clear(:layouts)
    end
  end
end