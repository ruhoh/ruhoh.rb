module Ruhoh::Resources::Dash
  class Collection
    include Ruhoh::Base::Collectable

    def url_endpoint
      "/dash"
    end
  
  end  
end