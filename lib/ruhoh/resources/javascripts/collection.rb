module Ruhoh::Resources::Javascripts
  class Collection < Ruhoh::Resources::Base::Collection
    def url_endpoint
      "assets/#{namespace}"
    end
  end
end