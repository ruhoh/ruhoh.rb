module Ruhoh::Base
  module Watchable
    def self.included(klass)
      klass.__send__(:attr_accessor, :collection)
    end

    def initialize(collection)
      @collection = collection
    end

    def update(path)
      # Drop the resource namespace
      matcher = File::ALT_SEPARATOR ?
                  %r{^.+(#{ File::SEPARATOR }|#{ File::ALT_SEPARATOR })} :
                  %r{^.+#{ File::SEPARATOR }}

      collection.touch(path.gsub(matcher, ''))
    end
  end

  # Base watcher class that loads if no custom Watcher class is defined.
  class Watcher
    include Watchable
  end
end