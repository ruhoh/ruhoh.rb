module Ruhoh::Resources::Theme
  class Watcher < Ruhoh::Resources::Base::Watcher
    def match(path)
      path =~ Regexp.new("^#{@collection.path}")
    end

    def update(path)
      @ruhoh.db.clear(:widgets)
      @ruhoh.db.clear(:layouts)
    end
  end
end