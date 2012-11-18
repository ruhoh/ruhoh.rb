class Ruhoh::Resources::Posts
  class View < Ruhoh::Views::RMustache
    include Ruhoh::Views::PageHelpers
  
    def all
      posts = @ruhoh.db.posts.each_value.map { |val| val }
      posts.sort! {
        |a,b| Date.parse(b['date']) <=> Date.parse(a['date'])
      }
    end
  
    # current_page is set via a compiler or previewer
    # in which it can discern what current_page to serve
    def paginator
      per_page = @ruhoh.db.config("paginator")["per_page"]
      current_page = self.context["page"]['current_page'].to_i rescue 0
      current_page = current_page.zero? ? 1 : current_page
      offset = (current_page-1)*per_page

      post_batch = all[offset, per_page]
      raise "Page does not exist" unless post_batch
      post_batch
    end
  
    def paginator_navigation
      config = @ruhoh.db.config("paginator")
      post_count = @ruhoh.db.posts.length
      total_pages = (post_count.to_f/config["per_page"]).ceil
      current_page = self.context["page"]['current_page'].to_i rescue 0
      current_page = current_page.zero? ? 1 : current_page
    
      pages = total_pages.times.map { |i| 
        {
          "url" => (i.zero? ? config["root_page"] : "#{config["namespace"]}#{i+1}"),
          "name" => "#{i+1}",
          "is_active_page" => (i+1 == current_page)
        }
      }
      pages 
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