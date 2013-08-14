module Ruhoh::Resources::Static
  class Collection
    include Ruhoh::Base::Collectable

    def url_endpoint
      resource_name
    end
  end
end
