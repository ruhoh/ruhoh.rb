module Ruhoh::Resources::Paginator
  class Parser < Ruhoh::Resources::Base::Parser
    def config
      hash = super
      hash["namepace"] ||=  "/index"
      hash["namepace"] = hash["namepace"].to_s
      unless hash["namepace"][0] == "/"
        hash["namepace"] = "/#{hash["namepace"]}"
      end
      hash["per_page"] ||=  5
      hash["per_page"] = hash["per_page"].to_i
      hash["layout"] ||=  "paginator"
      
      hash["root_page"] ||=  "/index"
      hash
    end

    def generate
    end
    
    def url_endpoint
      config["namespace"]
    end
  end
end  