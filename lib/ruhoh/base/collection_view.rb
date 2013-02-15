module Ruhoh::Base
  class CollectionView
    attr_accessor :master

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
    end

    def new_model_view(data={})
      return nil unless @ruhoh.resources.model_view?(resource_name)
      model_view = @ruhoh.resources.model_view(resource_name).new(@ruhoh, data)
      model_view.collection = self
      model_view.master = master
      model_view
    end

    def resource_name
      @collection.registered_name
    end
  end
end