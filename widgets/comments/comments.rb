class Ruhoh
  module Templaters
    module Helpers

      def comments
        return '' if self.context['page']['comments'].to_s == 'false'
        config = self.context['site']['config']['comments']
        return '' unless config && config['provider']
        code = self.partial("widgets/comments/#{config['provider']}")
        self.render(code)
      end

    end
  end
end