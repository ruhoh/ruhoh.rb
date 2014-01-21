require 'haml'
module Ruhoh::Views
  class HamlRenderer
    include Ruhoh::Views::Context

    def self.render(opts)
      context = new(opts)

      engine = ::Haml::Engine.new(opts[:template])

      engine.render(context.get_binding)
    end
  end
end
