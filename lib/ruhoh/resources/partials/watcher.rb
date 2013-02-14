module Ruhoh::Resources::Partials
  class Watcher < Ruhoh::Base::Watcher
    def match(path)
      path =~ %r{^(#{@collection.namespace}|#{@ruhoh.config['theme']['name']}\/partials)}
    end

    def update(path)
      @ruhoh.db.clear(:partials)
    end
  end
end