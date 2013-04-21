module Ruhoh::Resources::Theme
  class Collection < Ruhoh::Base::Collection

    def url_endpoint
      "/assets"
    end

    def namespace
      config["name"].to_s
    end

    # noop
    def process_all
      {}
    end
  end
end