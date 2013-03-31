module Ruhoh::Base
  class Model

    def initialize(ruhoh, pointer)
      @ruhoh = ruhoh
      @pointer = pointer
      @collection = @ruhoh.resources.load_collection(@pointer['resource'])
    end
    
    def config
      @collection.config
    end
    
  end
end