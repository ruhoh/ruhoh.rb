module Ruhoh::Plugins
  class Media < Plugin
    
    def url_endpoint
      "/assets/media"
    end
    
    class Modeler < BaseModeler
      
    end
 end
end