require '../views/helpers/categories'
require '../views/helpers/tags'
require '../views/helpers/paginator'

module Ruhoh::Collections::Pages
  class CollectionView < SimpleDelegator
    include Ruhoh::Collectable
    include Ruhoh::Views::Helpers::Tags
    include Ruhoh::Views::Helpers::Categories
    include Ruhoh::Views::Helpers::Paginator

    def initialize(data, ruhoh=nil)
      @ruhoh = ruhoh
      data.each do |item|
        item.collection = self
      end
      super(data)
    end

    def all
      each
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
      pages = sort{ |a, b| b["date"] <=> a["date"] }.to_a
      pages.each_with_index do |page, i|
        thisYear = page['date'].strftime('%Y')
        thisMonth = page['date'].strftime('%B')
        if (i-1 >= 0)
          prevYear = pages[i-1]['date'].strftime('%Y')
          prevMonth = pages[i-1]['date'].strftime('%B')
        end

        if(prevYear == thisYear) 
          if(prevMonth == thisMonth)
            collated.last['months'].last[collection_name] << page # append to last year & month
          else
            collated.last['months'] << {
                'month' => thisMonth,
                collection_name => [page]
              } # create new month
          end
        else
          collated << { 
            'year' => thisYear,
            'months' => [{ 
              'month' => thisMonth,
              collection_name => [page]
            }]
          } # create new year & month
        end

      end

      collated
    end
  end
end
