module Ruhoh::Base
  class ModelView < OpenStruct
    attr_accessor :collection, :master
    
    def initialize(ruhoh, data={})
      @ruhoh = ruhoh
      super(data) if data.is_a?(Hash)
    end
    
    def <=>(other)
      id <=> other.id
    end
    
    def [](attribute)
      __send__(attribute)
    end
    
    def []=(key, value)
      __send__("#{key}=", value)
    end
  end
end