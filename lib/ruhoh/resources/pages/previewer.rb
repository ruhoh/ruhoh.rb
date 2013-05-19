# Public: Rack application used to render singular pages via their URL.
module Ruhoh::Resources::Pages
  class Previewer

    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def call(env)
      return favicon if env['PATH_INFO'] == '/favicon.ico'

      # Always remove trailing slash if sent unless it's the root page.
      env['PATH_INFO'].chomp!("/") unless env['PATH_INFO'] == "/"

      pointer = @ruhoh.routes.find(env['PATH_INFO'])
      Ruhoh::Friend.say {
        plain "- previewing page:"
        plain "   #{pointer.inspect}"
      }

      view = pointer ? @ruhoh.master_view(pointer) : paginator_view(env)

      if view
        [200, {'Content-Type' => 'text/html'}, [view.render_full]]
      else
        message = "No generated page URL matches '#{ env['PATH_INFO'] }'" +
          " using file pointer: '#{ pointer.inspect }'."

        if pointer.nil?
          message += " Since the file pointer was nil" +
            " we tried to load a pagination view but it didn't work;" +
            "\n Expected the format to be: '<valid_resource_name>/page_number'"
        end

        raise message
      end
    end

    # Try the paginator.
    # search for the namespace and match it to a resource:
    # need a way to register pagination namespaces then search the register. 
    def paginator_view(env)
      path = env['PATH_INFO'].reverse.chomp("/").reverse
      resource = @ruhoh.collections.paginator_urls.find do |a, b|
        "/#{ path }" =~ %r{^#{ b }}
      end
      resource = resource[0] if resource
      return false unless resource

      page_number = path.match(/([1-9]+)$/)[0] rescue nil

      return false unless @ruhoh.collections.exist?(resource)
      return false if page_number.to_i.zero?

      collection = @ruhoh.collection(resource)
      config = collection.config["paginator"] || {}

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