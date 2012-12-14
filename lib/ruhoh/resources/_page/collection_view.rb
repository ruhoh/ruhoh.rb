require 'ruhoh/views/helpers/categories'
require 'ruhoh/views/helpers/tags'
module Ruhoh::Resources::Page
  
  class CollectionView < Ruhoh::Resources::Base::CollectionView
    include Ruhoh::Views::Helpers::Tags
    include Ruhoh::Views::Helpers::Categories
    
    # current_page is set via a compiler or previewer
    # in which it can discern what current_page to serve
    def paginator
      per_page = @ruhoh.db.config("paginator")["per_page"]
      current_page = master.context["page"]['current_page'].to_i rescue 0
      current_page = current_page.zero? ? 1 : current_page
      offset = (current_page-1)*per_page

      page_batch = all[offset, per_page]
      raise "Page does not exist" unless page_batch
      page_batch
    end

    def paginator_navigation
      config = @ruhoh.db.config("paginator")
      page_count = all.length
      total_pages = (page_count.to_f/config["per_page"]).ceil
      current_page = master.context["page"]['current_page'].to_i rescue 0
      current_page = current_page.zero? ? 1 : current_page
  
      pages = total_pages.times.map { |i| 
        {
          "url" => (i.zero? ? config["root_page"] : @ruhoh.to_url("#{config["namespace"]}#{i+1}")),
          "name" => "#{i+1}",
          "is_active_page" => (i+1 == current_page)
        }
      }
      pages 
    end
  end
end
