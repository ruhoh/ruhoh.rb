module Ruhoh::Resources::Page
  class Collection < Ruhoh::Resources::Base::Collection
    def config
      hash = super
      hash['permalink'] ||= "/:path/:filename"
      hash['summary_lines'] ||= 20
      hash['summary_lines'] = hash['summary_lines'].to_i
      hash['latest'] ||= 2
      hash['latest'] = hash['latest'].to_i
      hash['rss_limit'] ||= 20
      hash['rss_limit'] = hash['rss_limit'].to_i
      hash['ext'] ||= ".md"
      
      paginator = hash['paginator'] || {}
      paginator["namespace"] ||=  "/index"
      paginator["namespace"] = paginator["namespace"].to_s
      unless paginator["namespace"].start_with?('/')
        paginator["namespace"] = "/#{paginator["namespace"]}"
      end
      unless paginator["namespace"] == '/'
        paginator["namespace"] = paginator["namespace"].chomp('/') 
      end

      paginator["per_page"] ||=  5
      paginator["per_page"] = paginator["per_page"].to_i
      paginator["layout"] ||=  "paginator"

      if paginator["root_page"]
        unless paginator["root_page"].start_with?('/')
          paginator["root_page"] = "/#{paginator["root_page"]}"
        end
        unless paginator["root_page"] == '/'
          paginator["root_page"] = paginator["root_page"].chomp('/')
        end
      end

      hash['paginator'] = paginator

      hash
    end
  end
end