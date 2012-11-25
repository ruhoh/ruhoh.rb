module Ruhoh::Resources::Base
  class ModelView < OpenStruct
    attr_accessor :collection, :master

    def initialize(ruhoh, data={})
      @ruhoh = ruhoh
      super(data) if data.is_a?(Hash)
    end

    def [](attribute)
      __send__(attribute)
    end
  end
end