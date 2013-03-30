module Ruhoh::Resources::Data
  class CollectionView < OpenStruct
    attr_accessor :collection
    attr_accessor :master

    def initialize(collection)
      @ruhoh = collection.ruhoh
      super(collection.generate)
    end

    def [](attribute)
      __send__(attribute)
    end
  end
end
