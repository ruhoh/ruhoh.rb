module Ruhoh::Resources::Data
  class CollectionView < OpenStruct
    attr_accessor :collection
    attr_accessor :master

    def initialize(ruhoh)
      @ruhoh = ruhoh
      super(@ruhoh.db.data)
    end

    def [](attribute)
      __send__(attribute)
    end
  end
end
