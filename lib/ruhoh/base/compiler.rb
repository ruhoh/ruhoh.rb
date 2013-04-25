module Ruhoh::Base

  module Compilable
    def self.included(klass)
      __send__(:attr_reader, :collection)
    end

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
    end
  end

  class Compiler
    include Ruhoh::Base::Compilable
  end
end
