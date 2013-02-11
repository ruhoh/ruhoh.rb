module Ruhoh::Resources::Stylesheets
  class Collection < Ruhoh::Resources::Base::Collection
    def url_endpoint
      "assets/#{namespace}"
    end
  end
end