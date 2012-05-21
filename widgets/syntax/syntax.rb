class Ruhoh
  module Templaters
    module Helpers

      def syntax
        config = self.context['site']['config']['syntax']
        return '' unless config && config['provider']
        
        if config['provider'] == "custom"
          code = self.partial("custom_syntax")
        else
          code = self.partial("widgets/syntax/#{config['provider']}")
        end
        
        return "<h2 style='color:red'>!Syntax Provider partial for '#{config['provider']}' not found </h2>" if code.nil?

        self.render(code)
      end
      
    end
  end
end