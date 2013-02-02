module Ruhoh::Resources::Theme
  class Collection < Ruhoh::Resources::Base::Collection

    def url_endpoint
      "/assets"
    end

    def namespace
      config["name"].to_s
    end

    # noop
    def generate
      {}
    end
  end
end