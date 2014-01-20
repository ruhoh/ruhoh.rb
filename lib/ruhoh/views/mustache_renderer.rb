require 'mustache'
module Ruhoh::Views
  # Build a slightly customized Mustache interface.
  class RMustache < Mustache
    class RContext < Mustache::Context

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

  class MustacheRenderer < RMustache
    include Ruhoh::Views::Context

    def self.render(opts)
      new(opts).render(opts[:template].to_s)
    end

    def to_json(sub_context)
      sub_context.to_json
    end
  
    def to_pretty_json(sub_context)
      JSON.pretty_generate(sub_context)
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
      "<pre><code>#{code}</code></pre>\n"
    end
    
    # My Post Title ===> my-post-title
    # Handy for transforming ids into css-classes in your views.
    # @returns[String]
    def to_slug(sub_context)
      Silly::StringFormat.clean_slug(sub_context)
    end

    def gist
      @gist ||= Ruhoh::Views::Helpers::SimpleProxy.new({
        matcher: /^[0-9]+$/,
        function: -> input {
          "<script src=\"https://gist.github.com/#{ input }.js\"></script>"
        }
      })
    end
  end
end
