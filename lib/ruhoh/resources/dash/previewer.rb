module Ruhoh::Resources::Dash
  class Previewer
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def call(env)
      pointer = @ruhoh.collection("dash").find_file('index')
      view = @ruhoh.master_view(pointer)
      [200, {'Content-Type' => 'text/html'}, [view.render_full]]
    end
  end
end