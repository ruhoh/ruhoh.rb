class Ruhoh
  module Previewer

    # Public: Rack application used to render singular pages via their URL.
    class Page
    
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
    
      def call(env)
        return favicon if env['PATH_INFO'] == '/favicon.ico'

        # Always remove trailing slash if sent unless it's the root page.
        env['PATH_INFO'].gsub!(/\/$/, '') unless env['PATH_INFO'] == "/"
        
        pointer =  @ruhoh.db.routes[env['PATH_INFO']]
        raise "Page id not found for url: #{env['PATH_INFO']}" unless pointer
        page = @ruhoh.page(pointer)
        [200, {'Content-Type' => 'text/html'}, [page.render]]
      end
    
      def favicon
        [200, {'Content-Type' => 'image/x-icon'}, ['']]
      end

    end
  end
end