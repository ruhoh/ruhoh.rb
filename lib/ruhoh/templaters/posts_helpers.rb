class Ruhoh
  module Templaters
    module PostsHelpers
      
      # current_page is set via a compiler or previewer
      # in which it can discern what current_page to serve
      def posts_paginator
        per_page = @ruhoh.db.config("paginator")["per_page"]
        current_page = self.context["page"]['current_page'].to_i rescue 0
        current_page = current_page.zero? ? 1 : current_page
        offset = (current_page-1)*per_page

        post_batch = posts[offset, per_page]
        raise "Page does not exist" unless post_batch
        post_batch
      end
      
      def paginator_navigation
        config = @ruhoh.db.config("paginator")
        post_count = @ruhoh.db.posts.length
        total_pages = (post_count.to_f/config["per_page"]).ceil
        current_page = self.context["page"]['current_page'].to_i rescue 0
        current_page = current_page.zero? ? 1 : current_page

        total_pages.times.map { |i| 
          {
            "url" => (
              @ruhoh.to_url(i.zero? ? config["root_page"] : "#{config["namespace"]}#{i+1}")
            ),
            "name" => "#{i+1}",
            "is_active_page" => (i+1 == current_page)
          }
        }
      end
        
      def posts
        posts = @ruhoh.db.posts.each_value.map { |val| val }
        posts.sort! {
          |a,b| Date.parse(b['date']) <=> Date.parse(a['date'])
        }
      end

      def to_posts(sub_context)
        Array(sub_context).map { |id|
          @ruhoh.db.posts[id]
        }.compact
      end
      
      def posts_latest
        latest = @ruhoh.db.config("posts")['latest']
        latest ||= 10
        (latest.to_i > 0) ? self.posts[0, latest.to_i] : self.posts
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
      def posts_collated
        collated = []
        posts = self.posts
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
      
      
      # Categories
      ####################################################
      ####################################################

      # Array of category names
      def categories
        self.__categories.each_value.map { |cat| cat }
      end
      
      # Convert single or Array of category ids (names) to category hash(es).
      def to_categories(sub_context)
        Array(sub_context).map { |id|
          self.__categories[id] 
        }.compact
      end
      
      # Category dictionary
      def __categories
        categories_url = nil
        [@ruhoh.to_url("categories"), @ruhoh.to_url("categories.html")].each { |url|
          categories_url = url and break if @ruhoh.db.routes.key?(url)
        }
        categories = {}
        @ruhoh.db.posts.each_value do |post|
          Array(post['categories']).each do |cat|
            cat = Array(cat).join('/')
            if categories[cat]
              categories[cat]['count'] += 1
            else
              categories[cat] = { 
                'count' => 1, 
                'name' => cat, 
                'posts' => [],
                'url' => "#{categories_url}##{cat}-ref"
              }
            end 

            categories[cat]['posts'] << post['id']
          end
        end  
        categories
      end


      # Tags
      ####################################################
      ####################################################

      # Array of tag ids
      def tags
        self.__tags.each_value.map { |tag| tag }
      end
      
      # Convert single or Array of tag ids (names) to tag hash(es).
      def to_tags(sub_context)
        Array(sub_context).map { |id|
          self.__tags[id] 
        }.compact
      end

      # Generate the tags dictionary
      def __tags
        tags_url = nil
        [@ruhoh.to_url("tags"), @ruhoh.to_url("tags.html")].each { |url|
          tags_url = url and break if @ruhoh.db.routes.key?(url)
        }
        tags = {}
        @ruhoh.db.posts.each_value do |post|
          Array(post['tags']).each do |tag|
            if tags[tag]
              tags[tag]['count'] += 1
            else
              tags[tag] = { 
                'count' => 1, 
                'name' => tag,
                'posts' => [],
                'url' => "#{tags_url}##{tag}-ref"
              }
            end 

            tags[tag]['posts'] << post['id']
          end
        end  
        tags
      end

    end
  end
end
