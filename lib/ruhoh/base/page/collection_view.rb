require 'ruhoh/views/helpers/categories'
require 'ruhoh/views/helpers/tags'
module Ruhoh::Base::Page

  class CollectionView < Ruhoh::Base::CollectionView
    include Ruhoh::Views::Helpers::Tags
    include Ruhoh::Views::Helpers::Categories

    def all
      @ruhoh.db.__send__(resource_name).each_value.map { |data|
        next if (File.basename(File.dirname(data['id'])) == "drafts")
        new_model_view(data)
      }.compact.sort
    end

    def drafts
      @ruhoh.db.__send__(resource_name).each_value.map { |data|
        next unless (File.basename(File.dirname(data['id'])) == "drafts")
        new_model_view(data)
      }.compact.sort
    end

    def latest
      latest = @ruhoh.db.config(resource_name)['latest']
      latest ||= 10
      (latest.to_i > 0) ? all[0, latest.to_i] : all
    end

    # current_page is set via a compiler or previewer
    # in which it can discern what current_page to serve
    def paginator
      per_page = @ruhoh.db.config(resource_name)["paginator"]["per_page"] rescue 5
      current_page = master.page_data['current_page'].to_i
      current_page = current_page.zero? ? 1 : current_page
      offset = (current_page-1)*per_page

      page_batch = all[offset, per_page]
      raise "Page does not exist" unless page_batch
      page_batch
    end

    def paginator_navigation
      config = @ruhoh.db.config(resource_name)["paginator"] || {}
      page_count = all.length
      total_pages = (page_count.to_f/config["per_page"]).ceil
      current_page = master.page_data['current_page'].to_i
      current_page = current_page.zero? ? 1 : current_page
  
      pages = total_pages.times.map { |i| 
        url = if i.zero? && config["root_page"]
          config["root_page"]
        else
          "#{config["namespace"]}/#{i+1}"
        end
        
        {
          "url" => @ruhoh.to_url(url),
          "name" => "#{i+1}",
          "is_active_page" => (i+1 == current_page)
        }
      }
      pages 
    end

    # Internal: Create a collated pages data structure.
    #
    # pages - Required [Array] 
    #  Must be sorted chronologically beforehand.
    #
    # @returns[Array] collated pages:
    # [{ 'year': year, 
    #   'months' : [{ 'month' : month, 
    #     'pages': [{}, {}, ..] }, ..] }, ..]
    def collated
      collated = []
      pages = all
      pages.each_with_index do |page, i|
        thisYear = Time.parse(page['date']).strftime('%Y')
        thisMonth = Time.parse(page['date']).strftime('%B')
        if (i-1 >= 0)
          prevYear = Time.parse(pages[i-1]['date']).strftime('%Y')
          prevMonth = Time.parse(pages[i-1]['date']).strftime('%B')
        end

        if(prevYear == thisYear) 
          if(prevMonth == thisMonth)
            collated.last['months'].last[resource_name] << page['id'] # append to last year & month
          else
            collated.last['months'] << {
                'month' => thisMonth,
                resource_name => [page['id']]
              } # create new month
          end
        else
          collated << { 
            'year' => thisYear,
            'months' => [{ 
              'month' => thisMonth,
              resource_name => [page['id']]
            }]
          } # create new year & month
        end

      end

      collated
    end
  end
end
