module Ruhoh::Views  
  class RMustache < Mustache
  
    def initialize(ruhoh, context=nil)
      @ruhoh = ruhoh
      # pass the parent context into the sub-view
      @context = context if context
    end
    
    def self.inherited(base)
      name = base.name.chomp("::View").split("::").pop.downcase
      base.send(:define_method, "resource_name") do
        name
      end
    end
    
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
  
    def partial(name)
      p = @ruhoh.db.partials[name.to_s]
      Ruhoh::Friend.say { yellow "partial not found: '#{name}'" } if p.nil?
      p
    end
 
    def to_json(sub_context)
      sub_context.to_json
    end
  
    def debug(sub_context)
      Ruhoh::Friend.say { 
        yellow "?debug:"
        magenta sub_context.class
        cyan sub_context.inspect
      }

      "<pre>#{sub_context.class}\n#{sub_context.pretty_inspect}</pre>"
    end

    def raw_code(sub_context)
      code = sub_context.gsub('{', '&#123;').gsub('}', '&#125;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('_', "&#95;")
      "<pre><code>#{code}</code></pre>"
    end
  end
end
