module Ruhoh::Resources::Paginator
  class Previewer
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def call(env)
      # Always remove trailing slash if sent unless it's the root page.
      env['PATH_INFO'].gsub!(/\/$/, '') unless env['PATH_INFO'] == "/"
      path = env['PATH_INFO'].reverse.chomp("/").reverse
      view = @ruhoh.master_view({"resource" => "posts"})
      view.page_data = {
        "layout" => @ruhoh.db.config("paginator")["layout"],
        "current_page" => path
      }
      [200, {'Content-Type' => 'text/html'}, [view.render_full]]
    end
  end
end