module Ruhoh::Base
  class Compiler
    attr_reader :collection

    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collection = @ruhoh.resources.load_collection(resource_name)
    end

    def self.inherited(base)
      name = base.name.chomp("::Compiler").split("::").pop.downcase
      base.send(:define_method, "resource_name") do
        name
      end
      base.send(:define_method, "namespace") do
        Ruhoh::Base::Collection.resources[name]
      end
    end
  end
end
