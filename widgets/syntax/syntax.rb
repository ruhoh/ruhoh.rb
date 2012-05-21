class Ruhoh
  module Templaters
    module Helpers

      def syntax
        config = self.context['site']['config']['syntax']
        return '' unless config && config['provider']
        code = self.partial("widgets/syntax/#{config['provider']}")
        self.render(code)
      end
      
    end
  end
end