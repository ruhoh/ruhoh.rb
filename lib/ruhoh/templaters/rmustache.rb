class Ruhoh

  module Templaters  

    class RMustache < Mustache
      include Ruhoh::Templaters::Helpers

      class RContext < Context
    
        # Overload find method to catch helper expressions
        def find(obj, key, default = nil)
          return super unless key.to_s.index('?')
      
          puts "=> Executing helper: #{key}"
          context, helper = key.to_s.split('?')
          context = context.empty? ? obj : super(obj, context)

          self.mustache_in_stack.__send__ helper, context
        end  

      end #RContext
  
      def context
        @context ||= RContext.new(self)
      end

    end #RMustache
  
  end #Templaters

end #Ruhoh
