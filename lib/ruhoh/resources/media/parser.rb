module Ruhoh::Resources::Media
  class Parser < Ruhoh::Resources::Base::Parser
    def url_endpoint
      "/assets/media"
    end
  end
end