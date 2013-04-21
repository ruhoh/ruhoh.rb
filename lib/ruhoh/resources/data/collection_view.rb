module Ruhoh::Resources::Data
  class CollectionView < OpenStruct
    attr_accessor :collection
    attr_accessor :master

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
      super(@collection.dictionary)
    end

    def [](attribute)
      __send__(attribute)
    end

    def dictionary
      @collection.dictionary
    end

    def find_by_id(id)
      @collection.find_by_id(id)
    end
  end
end
