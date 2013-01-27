module Ruhoh::Resources::Layouts
  class Watcher < Ruhoh::Resources::Base::Watcher
    def match(path)
      path =~ Regexp.new("^#{@collection.path}")
    end

    def update(path)
      @ruhoh.db.clear(:layouts)
    end
  end
end