module Ruhoh::Resources::Posts
  class View < Ruhoh::Resources::Core::Pages::View

    def all
      posts = @ruhoh.db.posts.each_value.map { |val| val }
      posts.sort {
        |a,b| Date.parse(b['date']) <=> Date.parse(a['date'])
      }.map {|data|
        new_single(data)
      }
    end
    
    def latest
      latest = @ruhoh.db.config("posts")['latest']
      latest ||= 10
      (latest.to_i > 0) ? self.all[0, latest.to_i] : self.all
    end
  
    # Internal: Create a collated posts data structure.
    #
    # posts - Required [Array] 
    #  Must be sorted chronologically beforehand.
    #
    # [{ 'year': year, 
    #   'months' : [{ 'month' : month, 
    #     'posts': [{}, {}, ..] }, ..] }, ..]
    # 
    def collated
      collated = []
      posts = self.all
      posts.each_with_index do |post, i|
        thisYear = Time.parse(post['date']).strftime('%Y')
        thisMonth = Time.parse(post['date']).strftime('%B')
        if (i-1 >= 0)
          prevYear = Time.parse(posts[i-1]['date']).strftime('%Y')
          prevMonth = Time.parse(posts[i-1]['date']).strftime('%B')
        end

        if(prevYear == thisYear) 
          if(prevMonth == thisMonth)
            collated.last['months'].last['posts'] << post['id'] # append to last year & month
          else
            collated.last['months'] << {
                'month' => thisMonth,
                'posts' => [post['id']]
              } # create new month
          end
        else
          collated << { 
            'year' => thisYear,
            'months' => [{ 
              'month' => thisMonth,
              'posts' => [post['id']]
            }]
          } # create new year & month
        end

      end

      collated
    end
    
  end
end