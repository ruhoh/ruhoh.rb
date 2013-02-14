module Ruhoh::Base
  class CollectionView
    attr_accessor :master

    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collection = ruhoh.resources.load_collection(resource_name)
    end

    def self.inherited(base)
      name = base.name.chomp("::CollectionView").split("::").pop.downcase
      base.send(:define_method, "resource_name") do
        name
      end
      base.send(:define_method, "namespace") do
        Ruhoh::Base::Collection.resources[name]
      end
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