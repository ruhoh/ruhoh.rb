class Ruhoh
  module Templaters
    module Helpers

      def analytics
        return '' if self.context['page']['analytics'].to_s == 'false'
        config = self.context['site']['config']['analytics']
        return '' unless config && config['provider']
        code = self.partial("widgets/analytics/#{config['provider']}")
        self.render(code)
      end
      
    end
  end
end

