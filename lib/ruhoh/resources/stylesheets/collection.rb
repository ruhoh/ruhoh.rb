module Ruhoh::Resources::Stylesheets
  class Collection
    include Ruhoh::Base::Collectable

    def url_endpoint
      "assets/#{ resource_name }"
    end
  end
end