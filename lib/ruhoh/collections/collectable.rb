class Ruhoh
  # Reusable interface for CollectionView classes.
  module Collectable
    def self.included(klass)
      klass.__send__(:attr_accessor, :collection_name, :master)
    end

    def config
      @ruhoh.config.collection(collection_name)
    end
  end
end
