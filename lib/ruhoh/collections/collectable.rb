class Ruhoh
  # Reusable interface for CollectionView classes.
  module Collectable
    def self.included(klass)
      klass.__send__(:attr_accessor, :collection_name, :master)
    end

    def config
      @ruhoh.config.collection(collection_name)
    end

    def data
      return @_data if @_data
      item = @ruhoh.query.path(collection_name).where("$shortname" => "data").first
      @_data = item ? item.data : {}
    end
  end
end
