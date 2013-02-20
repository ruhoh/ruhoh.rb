# Public: Rack application used to render singular pages via their URL.
module Ruhoh::Base::Pages
  class Previewer

    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def call(env)
      return favicon if env['PATH_INFO'] == '/favicon.ico'

      # Always remove trailing slash if sent unless it's the root page.
      env['PATH_INFO'].chomp!("/") unless env['PATH_INFO'] == "/"

      pointer = @ruhoh.db.routes[env['PATH_INFO']]
      view = pointer ? @ruhoh.master_view(pointer) : paginator_view(env)

      if view
        [200, {'Content-Type' => 'text/html'}, [view.render_full]]
      else
        raise "Page id not found for url: #{env['PATH_INFO']}"
      end
    end

    # Try the paginator.
    # search for the namespace and match it to a resource:
    # need a way to register pagination namespaces then search the register. 
    def paginator_view(env)
      path = env['PATH_INFO'].reverse.chomp("/").reverse
      resource = path.split('/').first
      return nil unless @ruhoh.resources.exist?(resource)
      
      collection = @ruhoh.resources.load_collection(resource)
      config = collection.config["paginator"] || {}
      page_number = path.split('/').pop

      view = @ruhoh.master_view({"resource" => resource})
      view.page_data = {
        "layout" => config["layout"],
        "current_page" => page_number
      }
      view
    end

    def favicon
      [200, {'Content-Type' => 'image/x-icon'}, ['']]
    end

  end
end