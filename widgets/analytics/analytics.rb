class Ruhoh
  module Templaters
    module Helpers

      def analytics
        return '' if self.context['page']['analytics'].to_s == 'false'
        config = self.context['site']['config']['analytics']
        return '' unless config && config['provider']

        if config['provider'] == "custom"
          code = self.partial("custom_analytics")
        else
          code = self.partial("widgets/analytics/#{config['provider']}")
        end

        return "<h2 style='color:red'>!Analytics Provider partial for '#{config['provider']}' not found </h2>" if code.nil?

        self.render(code)
      end
      
    end
  end
end

