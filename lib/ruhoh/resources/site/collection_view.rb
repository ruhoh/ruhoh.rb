module Ruhoh::Resources::Site
  class CollectionView < OpenStruct
    attr_accessor :collection
    attr_accessor :master

    def initialize(ruhoh, context={})
      @ruhoh = ruhoh
      super(@ruhoh.db.site)
    end

    def [](attribute)
      __send__(attribute)
    end
  end
end
