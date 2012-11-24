module Ruhoh::Resources::Dash
  class Previewer
    def initialize(resource)
      @resource = resource
      @ruhoh = resource.ruhoh
    end

    def call(env)
      page = @ruhoh.page(@ruhoh.db.dash)
      [200, {'Content-Type' => 'text/html'}, [page.render_full]]
    end
  end
end