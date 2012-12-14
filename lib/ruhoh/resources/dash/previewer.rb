module Ruhoh::Resources::Dash
  class Previewer
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def call(env)
      page = @ruhoh.page(@ruhoh.db.dash)
      [200, {'Content-Type' => 'text/html'}, [page.render_full]]
    end
  end
end