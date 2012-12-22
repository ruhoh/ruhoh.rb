module Ruhoh::Resources::Dash
  class Previewer
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def call(env)
      view = @ruhoh.master_view(@ruhoh.db.dash)
      [200, {'Content-Type' => 'text/html'}, [view.render_full]]
    end
  end
end