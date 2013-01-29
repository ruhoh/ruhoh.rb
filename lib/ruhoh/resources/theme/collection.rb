module Ruhoh::Resources::Theme
  class Collection < Ruhoh::Resources::Base::Collection

    def config
      hash = super
      if hash['name'].empty?
        Ruhoh.log.error("Theme not specified in config.yml")
        return false
      end
      hash
    end

    def url_endpoint
      "/assets/#{config['name']}"
    end

    def path
      config["name"]
    end

    # noop
    def generate
      {}
    end
  end
end