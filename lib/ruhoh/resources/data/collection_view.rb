module Ruhoh::Resources::Data
  class CollectionView < OpenStruct
    attr_accessor :collection
    attr_accessor :master

    def initialize(collection)
      @ruhoh = collection.ruhoh
      super(@ruhoh.db.__send__(collection.resource_name))
    end

    def [](attribute)
      __send__(attribute)
    end
  end
end
