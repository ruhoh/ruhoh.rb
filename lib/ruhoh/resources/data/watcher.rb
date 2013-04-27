module Ruhoh::Resources::Data
  class Watcher
    include Ruhoh::Base::Watchable

    def match(path)
      path == "data.yml"
    end

  end
end