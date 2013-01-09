module Ruhoh::Resources::Paginator
  class Collection < Ruhoh::Resources::Base::Collection
    def config
      hash = super

      hash["namespace"] ||=  "/index"
      hash["namespace"] = hash["namespace"].to_s
      unless hash["namespace"].start_with?('/')
        hash["namespace"] = "/#{hash["namespace"]}"
      end

      hash["per_page"] ||=  5
      hash["per_page"] = hash["per_page"].to_i
      hash["layout"] ||=  "paginator"

      hash["root_page"] ||=  hash["namespace"]
      unless hash["root_page"].start_with?('/')
        hash["root_page"] = "/#{hash["root_page"]}"
      end

      hash
    end

    def generate
    end
    
    def url_endpoint
      config["namespace"]
    end
  end
end  