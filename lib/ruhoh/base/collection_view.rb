module Ruhoh::Base
  class CollectionView
    attr_accessor :master

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
    end

    def new_model_view(data={})
      return nil unless @ruhoh.resources.model_view?(resource_name)
      model_view = @ruhoh.resources.load_model_view(resource_name, data)
      model_view.collection = self
      model_view.master = master
      model_view
    end

    def resource_name
      @collection.resource_name
    end
  end
end