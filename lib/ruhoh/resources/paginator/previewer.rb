module Ruhoh::Resources::Paginator
  class Previewer
    def initialize(resource)
      @resource = resource
      @ruhoh = resource.ruhoh
    end

    def call(env)
      # Always remove trailing slash if sent unless it's the root page.
      env['PATH_INFO'].gsub!(/\/$/, '') unless env['PATH_INFO'] == "/"
      path = env['PATH_INFO'].reverse.chomp("/").reverse
      page = @ruhoh.page({"resource" => "posts"})
      page.data = {
        "layout" => @ruhoh.db.config("paginator")["layout"],
        "current_page" => path
      }
      [200, {'Content-Type' => 'text/html'}, [page.render_full]]
    end
  end
end