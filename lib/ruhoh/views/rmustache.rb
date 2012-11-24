module Ruhoh::Views  
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
