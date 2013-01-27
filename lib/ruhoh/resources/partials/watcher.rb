module Ruhoh::Resources::Partials
  class Watcher < Ruhoh::Resources::Base::Watcher
    def match(path)
      path =~ %r{^(#{@collection.path}|#{@ruhoh.config['theme']['name']}\/partials)}
    end

    def update(path)
      @ruhoh.db.clear(:partials)
    end
  end
end