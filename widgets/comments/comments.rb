class Ruhoh
  module Templaters
    module Helpers

      def comments
        return '' if self.context['page']['comments'].to_s == 'false'
        config = self.context['site']['config']['comments']
        return '' unless config && config['provider']
        
        if config['provider'] == "custom"
          code = self.partial("custom_comments")
        else
          code = self.partial("widgets/comments/#{config['provider']}")
        end
        
        return "<h2 style='color:red'>!Comments Provider partial for '#{config['provider']}' not found </h2>" if code.nil?

        self.render(code)
      end

    end
  end
end