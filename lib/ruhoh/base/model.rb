module Ruhoh::Base
  class Model

    def initialize(ruhoh, pointer)
      @ruhoh = ruhoh
      @pointer = pointer
    end

    def collection
      @ruhoh.resources.load_collection(@pointer['resource'])
    end
  end
end