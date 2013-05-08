module Ruhoh::Resources::Theme
  class Collection
    include Ruhoh::Base::Collectable

    def url_endpoint
      "/assets"
    end

    # noop
    def dictionary
      {}
    end
  end
end