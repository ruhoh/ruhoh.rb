require 'ruhoh/views/helpers/categories'
require 'ruhoh/views/helpers/tags'
require 'ruhoh/views/helpers/paginator'
module Ruhoh::Resources::Pages

  class CollectionView < SimpleDelegator
    include Ruhoh::Views::Helpers::Tags
    include Ruhoh::Views::Helpers::Categories
    include Ruhoh::Views::Helpers::Paginator

    def all
      dictionary.each_value.find_all { |model|
        File.basename(File.dirname(model.id)) != "drafts"
      }.sort
    end

    def drafts
      dictionary.each_value.find_all { |model|
        File.basename(File.dirname(model.id)) == "drafts"
      }.sort
    end

    def latest
      latest = config['latest']
      latest ||= 10
      (latest.to_i > 0) ? all[0, latest.to_i] : all
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
