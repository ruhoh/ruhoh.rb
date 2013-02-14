module Ruhoh::Base
  class Model

    def initialize(ruhoh, pointer)
      @ruhoh = ruhoh
      @pointer = pointer
    end
    
    def config
      @ruhoh.db.config(@pointer['resource'])
    end
    
  end
end