module Ruhoh::Resources::Base
  class Compiler

    def initialize(ruhoh)
      @ruhoh = ruhoh
    end
    
    def self.inherited(base)
      name = base.name.chomp("::Compiler").split("::").pop.downcase
      base.send(:define_method, "resource_name") do
        name
      end
      base.send(:define_method, "namespace") do
        Ruhoh::Resources::Base::Collection.resources[name]
      end
    end
  end
end
