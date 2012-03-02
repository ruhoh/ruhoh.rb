class Ruhoh
  
  class HelperMustache < Mustache

    class HelperContext < Context
    
      # Overload find method to catch helper expressions
      def find(obj, key, default = nil)
        return super unless key.to_s.index('?')
      
        puts "=> Executing helper: #{key}"
        context, helper = key.to_s.split('?')
        context = context.empty? ? obj : super(obj, context)

        self.mustache_in_stack.__send__ helper, context
      end  

    end #HelperContext
  
    def context
      @context ||= HelperContext.new(self)
    end
  
    def partials
      @partials ||= Ruhoh::Database.get(:partials)
    end
  
    def partial(name)
      self.partials[name.to_s]
    end
  
    def to_tags(sub_context)
      if sub_context.is_a?(Array)
        sub_context.map { |id|
          self.context['_posts']['tags'][id] if self.context['_posts']['tags'][id]
        }
      else
        tags = []
        self.context['_posts']['tags'].each_value { |tag|
          tags << tag
        }
        tags
      end
    end
  
    def to_posts(sub_context)
      sub_context = sub_context.is_a?(Array) ? sub_context : self.context['_posts']['chronological']
    
      sub_context.map { |id|
        self.context['_posts']['dictionary'][id] if self.context['_posts']['dictionary'][id]
      }
    end
  
    def to_pages(sub_context)
      puts "=> call: pages_list with context: #{sub_context}"
      pages = []
      if sub_context.is_a?(Array) 
        sub_context.each do |id|
          if self.context[:pages][id]
            pages << self.context[:pages][id]
          end
        end
      else
        self.context[:pages].each_value {|page| pages << page }
      end
      pages
    end
  
  end #HelperMustache
  
end #Ruhoh