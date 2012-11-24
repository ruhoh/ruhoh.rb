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
  
  class RMustache < Mustache
    class RContext < Context

      # Overload find method to catch helper expressions
      def find(obj, key, default = nil)
        return super unless key.to_s.index('?')
        keys = key.to_s.split('?')
        context = keys[0]
        helpers = keys[1..-1]
        context = context.empty? ? obj : super(obj, context)
        
        helpers.each do |helper|
          context = self.mustache_in_stack.__send__ helper, context
        end
        context
      end
    end
  
    def context
      @context ||= RContext.new(self)
    end
  end
end
