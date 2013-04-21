module Ruhoh::Resources::Data
  class CollectionView < OpenStruct
    attr_accessor :collection
    attr_accessor :master

    extend Forwardable

    def_instance_delegators :@collection, :dictionary, :find_by_id, :find_by_name, :load_model_view

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
      super(@collection.dictionary)
    end

    def [](attribute)
      __send__(attribute)
    end

  end
end
