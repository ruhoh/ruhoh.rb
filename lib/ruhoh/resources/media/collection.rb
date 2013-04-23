module Ruhoh::Resources::Media
  class Collection
    include Ruhoh::Base::Collectable

    def url_endpoint
      "/assets/media"
    end
  end
end