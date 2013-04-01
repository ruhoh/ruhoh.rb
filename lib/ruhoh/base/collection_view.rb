require 'delegate'
module Ruhoh::Base
  class CollectionView < SimpleDelegator
    attr_accessor :master

    def initialize(collection)
      @ruhoh = collection.ruhoh
      super(collection)
    end

    def new_model_view(data={})
      return nil unless model_view?
      model_view = load_model_view(data)
      model_view.collection = self
      model_view.master = master
      model_view
    end
  end
end