require 'ruhoh/templaters/base_helpers'
require 'ruhoh/templaters/asset_helpers'
require 'ruhoh/templaters/helpers'

class Ruhoh
  module Templaters  
    class RMustache < Mustache
      include Ruhoh::Templaters::BaseHelpers
      include Ruhoh::Templaters::AssetHelpers
      include Ruhoh::Templaters::Helpers

      class RContext < Context
    
        # Overload find method to catch helper expressions
        def find(obj, key, default = nil)
          return super unless key.to_s.index('?')
          context, helper = key.to_s.split('?')
          context = context.empty? ? obj : super(obj, context)

          self.mustache_in_stack.__send__ helper, context
        end  
      end #RContext
  
      def context
        @context ||= RContext.new(self)
      end
      
      # Lazy-load the page body.
      # When in a global scope (layouts, pages), the content is for the current page.
      # May also be called in sub-contexts such as looping through posts.
      #
      #  {{# posts }}
      #    {{{ content }}}
      #  {{/ posts }}
      def content
        content, id = self.get_page_content
        content = self.render(content)
        Ruhoh::Converter.convert(content, id)
      end
      
      def get_page_content
        id = self.context['id']
        id ||= self.context['page']['id']
        return '' unless id
        unless id =~ Regexp.new("^#{Ruhoh.names.posts}")
          id = "#{Ruhoh.names.pages}/#{id}"
        end
        
        [Ruhoh::Utils.parse_page_file(Ruhoh.paths.base, id)['content'], id]
      end
      
      def widget(name)
        return '' if self.context['page'][name.to_s].to_s == 'false'
        raw_layout = Ruhoh::DB.widgets[name.to_s]['layout']
        self.render(raw_layout)
      end
      
      def method_missing(name, *args, &block)
        return self.widget(name.to_s) if Ruhoh::DB.widgets.has_key?(name.to_s)
        super
      end

      def respond_to?(method)
        return true if Ruhoh::DB.widgets.has_key?(method.to_s)
        super
      end
      
    end #RMustache
  end #Templaters
end #Ruhoh
