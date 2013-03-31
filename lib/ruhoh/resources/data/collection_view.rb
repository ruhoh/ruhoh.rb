module Ruhoh::Resources::Data
  class CollectionView < OpenStruct
    attr_accessor :collection
    attr_accessor :master

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
      super(@collection.generate)
    end

    def [](attribute)
      __send__(attribute)
    end

    def generate
      @collection.generate
    end
  end
end
