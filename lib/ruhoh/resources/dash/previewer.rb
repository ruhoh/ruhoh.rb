module Ruhoh::Resources::Dash
  class Previewer
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def call(env)
      data = @ruhoh.resources.load_collection("dash").generate
      view = @ruhoh.master_view(data)
      [200, {'Content-Type' => 'text/html'}, [view.render_full]]
    end
  end
end