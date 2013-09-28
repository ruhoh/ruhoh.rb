module Ruhoh::Base::Watchable
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
