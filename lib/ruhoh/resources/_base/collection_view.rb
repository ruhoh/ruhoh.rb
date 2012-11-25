module Ruhoh::Resources::Base
  class CollectionView
    attr_accessor :master, :context

    def initialize(ruhoh, context=nil)
      @ruhoh = ruhoh
      @context = context if context
    end
    
    def self.inherited(base)
      name = base.name.chomp("::CollectionView").split("::").pop.downcase
      base.send(:define_method, "resource_name") do
        name
      end
      base.send(:define_method, "namespace") do
        Ruhoh::Resources::Base::Parser.resources[name]
      end
    end
    
    # Create new singleton resource w/ access to resources collection and master view.
    def new_single(data={})
      return nil unless namespace.const_defined?(:Single)
      single = namespace.const_get(:Single).new(@ruhoh, data)
      single.collection = self
      single.master = master
      single
    end
  end
end