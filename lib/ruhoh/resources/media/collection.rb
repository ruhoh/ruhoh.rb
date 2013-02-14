module Ruhoh::Resources::Media
  class Collection < Ruhoh::Base::Collection
    def url_endpoint
      "/assets/media"
    end
  end
end