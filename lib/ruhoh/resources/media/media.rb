module Ruhoh::Resources::Media
  class Parser < Ruhoh::Resources::Resource
    def url_endpoint
      "/assets/media"
    end
  end

  class Modeler < Ruhoh::Resources::BaseModeler
    
  end
end