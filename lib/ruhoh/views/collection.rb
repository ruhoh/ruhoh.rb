module Ruhoh::Views  
  class Collection
    attr_accessor :master, :context

    def initialize(ruhoh, context=nil)
      @ruhoh = ruhoh
      @context = context if context
    end
    
    def self.inherited(base)
      name = base.name.chomp("::View").split("::").pop.downcase
      base.send(:define_method, "resource_name") do
        name
      end
    end
  end
end