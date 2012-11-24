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
    
    # Model a single instance of a Page object
    class BaseSingle < OpenStruct
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
end