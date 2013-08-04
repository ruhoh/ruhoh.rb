module Ruhoh::Views::Helpers
  module Paginator
    # current_page is set via a compiler or previewer
    # in which it can discern what current_page to serve
    def paginator
      per_page = config["paginator"]["per_page"] rescue 5
      current_page = master.page_data['current_page'].to_i
      current_page = current_page.zero? ? 1 : current_page
      offset = (current_page-1)*per_page

      page_batch = all[offset, per_page]
      raise "Page does not exist" unless page_batch
      page_batch
    end

    # [1][2] ... [n-1][n][n+1] ... [last-1][last]
    def paginator_navigation
      paginator_config = config["paginator"] || {}
      page_count = all.length
      total_pages = (page_count.to_f/paginator_config["per_page"]).ceil
      current_page = master.page_data['current_page'].to_i
      current_page = current_page.zero? ? 1 : current_page

#      pages = total_pages.times.map { |i| 
#        url = if i.zero? && paginator_config["root_page"]
#                paginator_config["root_page"]
#              else
#                "#{paginator_config["url"]}/#{i+1}"
#              end
#
#        {
#          "url" => ruhoh.to_url(url),
#          "name" => "#{i+1}",
#          "is_active_page" => (i+1 == current_page)
#        }
#     }
      left_dots = ((current_page+1)/2).ceil
      right_dots = ((total_pages+current_page)/2).ceil
      borders = paginator_config["borders"]

      pages = total_pages.times.select { |i|
        i+1 <= borders || i+1 > total_pages-borders || 
        (i+1 >= current_page-(borders/2).ceil && i+1 <= current_page+(borders/2).ceil) || 
        i+1 == left_dots || i+1 == right_dots                    
      }.map { |i|
        ii=i+1
        url = if i.zero? && paginator_config["root_page"]
                paginator_config["root_page"]
              else
                "#{paginator_config["url"]}/#{ii}"
              end
        name = (i+1 > borders) && (i+1 < total_pages-borders) && 
               ((i+1 < current_page-(borders/2).ceil) || (i+1 > current_page+(borders/2).ceil)) && 
               (i+1 == left_dots || i+1 == right_dots) ? '…' : "#{i+1}"
        {
          "url" => ruhoh.to_url(url),
          "name" => name,
          "is_active_page" => (i+1 == current_page),
          "title" => "#{i+1}"
        }
      }
      pages 
    end
  end
end