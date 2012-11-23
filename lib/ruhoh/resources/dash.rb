module Ruhoh::Resources::Dash
  class Parser < Ruhoh::Resources::Resource
    
    def url_endpoint
      "/dash"
    end
  
  end  

  class Modeler < Ruhoh::Resources::BaseModeler
    include Ruhoh::Resources::Page

    def generate
      @pointer
    end
    
  end
    
  class Previewer
    def initialize(resource)
      @resource = resource
      @ruhoh = resource.ruhoh
    end

    def call(env)
      page = @ruhoh.page(@ruhoh.db.dash)
      [200, {'Content-Type' => 'text/html'}, [page.render_full]]
    end
  end
  
end