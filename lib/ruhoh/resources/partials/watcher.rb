module Ruhoh::Resources::Partials
  class Watcher
    include Ruhoh::Base::Watchable

    def match(path)
      path =~ %r{^(#{@collection.namespace}|#{@ruhoh.config['theme']['name']}\/partials)}
    end
  end
end