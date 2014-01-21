require 'erb'

module Ruhoh::Views
  class ErbRenderer
    include Ruhoh::Views::Context

    def self.render(opts)
      context = new(opts)

      ERB.new(opts[:template]).result(context.get_binding)
    end
  end
end
