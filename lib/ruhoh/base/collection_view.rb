require 'delegate'
module Ruhoh::Base
  class CollectionView < SimpleDelegator
    def initialize(collection)
      @ruhoh = collection.ruhoh
      super(collection)
    end
  end
end