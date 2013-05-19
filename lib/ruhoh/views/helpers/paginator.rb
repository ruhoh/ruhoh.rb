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

    def paginator_navigation
      paginator_config = config["paginator"] || {}
      page_count = all.length
      total_pages = (page_count.to_f/paginator_config["per_page"]).ceil
      current_page = master.page_data['current_page'].to_i
      current_page = current_page.zero? ? 1 : current_page

      pages = total_pages.times.map { |i| 
        url = if i.zero? && paginator_config["root_page"]
                paginator_config["root_page"]
              else
                "#{paginator_config["url"]}/#{i+1}"
              end

        {
          "url" => ruhoh.to_url(url),
          "name" => "#{i+1}",
          "is_active_page" => (i+1 == current_page)
        }
      }
      pages 
    end
  end
end