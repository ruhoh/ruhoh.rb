module Ruhoh::Resources
  class Media < Resource
    
    def url_endpoint
      "/assets/media"
    end
    
    class Modeler < BaseModeler
      
    end
 end
end