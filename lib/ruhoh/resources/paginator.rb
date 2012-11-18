module Ruhoh::Resources
  class Paginator < Resource
    
    def config
      hash = super
      hash["namepace"] ||=  "/index"
      hash["namepace"] = hash["namepace"].to_s
      unless hash["namepace"][0] == "/"
        hash["namepace"] = "/#{hash["namepace"]}"
      end
      hash["per_page"] ||=  5
      hash["per_page"] = hash["per_page"].to_i
      hash["layout"] ||=  "paginator"
      
      hash["root_page"] ||=  "/index"
      hash
    end

    def generate
    end
    
    def url_endpoint
      config["namespace"]
    end
    
    class Previewer
      def initialize(resource)
        @resource = resource
        @ruhoh = resource.ruhoh
      end

      def call(env)
        # Always remove trailing slash if sent unless it's the root page.
        env['PATH_INFO'].gsub!(/\/$/, '') unless env['PATH_INFO'] == "/"
        path = env['PATH_INFO'].reverse.chomp("/").reverse
        page = @ruhoh.page("nothing")
        page.data = {
          "layout" => @ruhoh.db.config("paginator")["layout"],
          "current_page" => path,
          "pointer" => {
            "parser" => "posts"
          }
        }
        [200, {'Content-Type' => 'text/html'}, [page.render]]
      end
    end
    
  end
end  