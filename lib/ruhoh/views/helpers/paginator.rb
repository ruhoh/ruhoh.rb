module Ruhoh::Views::Helpers
  module Paginator

    # master.page.page_number is set via a compiler or previewer
    def paginator_config
      c = config["paginator"] || {}
      c["per_page"] ||= 5
      c["url"] ||= "#{ collection_name }/index"
      c["page_number"] = master.page.page_number.to_i
      c["page_number"] = 1 if c["page_number"].zero?
      c
    end

    # in which it can discern what page_number to serve
    def paginator
      offset = (paginator_config["page_number"]-1)*paginator_config["per_page"]
      page_batch = self[offset, paginator_config["per_page"]]
      raise "Page does not exist" unless page_batch

      page_batch
    end

    def paginator_navigation
      total_pages = (self.length.to_f/paginator_config["per_page"]).ceil

      total_pages.times.map do |i|
        url = if i.zero? && paginator_config["root_page"]
                paginator_config["root_page"]
              else
                "#{ paginator_config["url"] }/#{ i + 1 }"
              end

        {
          "url" => @ruhoh.to_url(url),
          "name" => "#{i+1}",
          "is_active_page" => (i+1 == paginator_config["page_number"])
        }
      end
    end
  end
end