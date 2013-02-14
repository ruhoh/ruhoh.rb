module Ruhoh::Resources::Layouts
  class Watcher < Ruhoh::Base::Watcher
    def match(path)
      path =~ Regexp.new("^#{@collection.namespace}")
    end

    def update(path)
      @ruhoh.db.clear(:layouts)
    end
  end
end