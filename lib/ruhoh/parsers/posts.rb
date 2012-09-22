class Ruhoh
  module Parsers
    class Posts < Base
      
      def paths
        [@ruhoh.paths.base]
      end
      
      def glob
        "#{Ruhoh.names.posts}/**/*.*"
      end
      
      def is_valid_page?(filepath)
        return false if FileTest.directory?(filepath)
        return false if ['.'].include? filepath[0]
        @ruhoh.config.posts_exclude.each {|regex| return false if filepath =~ regex }
        true
      end


      # Public: Generate the Posts dictionary.
      def generate
        dict = super
        dictionary = {}
        drafts = []
        invalid = []
        
        Ruhoh::Utils.report('Posts', dictionary, invalid)
        
        results = { 
          "posts" => dictionary,
          "drafts" => drafts
        }
        
        ordered_posts = self.ordered_posts(results['posts'])

        {
          'dictionary'      => results['posts'],
          'drafts'          => results['drafts'],
          'chronological'   => self.build_chronology(ordered_posts),
          'collated'        => self.collate(ordered_posts),
          'tags'            => self.parse_tags(ordered_posts),
          'categories'      => self.parse_categories(ordered_posts)
        }
      end
      
      def ordered_posts(dictionary)
        ordered_posts = []
        dictionary.each_value { |val| ordered_posts << val }
        ordered_posts.sort! {
          |a,b| Date.parse(b['date']) <=> Date.parse(a['date'])
        }

        ordered_posts
      end
      
      def build_chronology(ordered_posts)
        ordered_posts.map { |post| post['id'] }
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
      def collate(ordered_posts)
        collated = []
        ordered_posts.each_with_index do |post, i|
          thisYear = Time.parse(post['date']).strftime('%Y')
          thisMonth = Time.parse(post['date']).strftime('%B')
          if (i-1 >= 0)
            prevYear = Time.parse(ordered_posts[i-1]['date']).strftime('%Y')
            prevMonth = Time.parse(ordered_posts[i-1]['date']).strftime('%B')
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

      def parse_tags(ordered_posts)
        tags = {}

        ordered_posts.each do |post|
          Array(post['tags']).each do |tag|
            if tags[tag]
              tags[tag]['count'] += 1
            else
              tags[tag] = { 
                'count' => 1, 
                'name' => tag,
                'posts' => [] 
              }
            end 

            tags[tag]['posts'] << post['id']
          end
        end  
        tags
      end

      def parse_categories(ordered_posts)
        categories = {}
      
        ordered_posts.each do |post|
          Array(post['categories']).each do |cat|
            cat = Array(cat).join('/')
            if categories[cat]
              categories[cat]['count'] += 1
            else
              categories[cat] = { 
                'count' => 1, 
                'name' => cat, 
                'posts' => []
              }
            end 

            categories[cat]['posts'] << post['id']
          end
        end  
        categories
      end
    
    
      class Modeler < BaseModeler
        include Page
        
        DateMatcher = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/
        Matcher = /^(.+\/)*(.*)(\.[^.]+)$/

        def generate
          type = "post"
          parsed_page = self.parse_page_file
          data = parsed_page['data']
  
          filename_data = self.parse_page_filename(@id)
          if filename_data.empty?
            #error = "Invalid Filename Format. Format should be: my-post-title.ext"
            #invalid << [@id, error] ; next
          end
  
          data['date'] ||= filename_data['date']

          unless self.formatted_date(data['date'])
            #error = "Invalid Date Format. Date should be: YYYY-MM-DD"
            #invalid << [@id, error] ; next
          end

          if data['type'] == 'draft'
            return {"_type" => "draft"} if @ruhoh.config.env == 'production'
          end  
  
          data['date']          = data['date'].to_s
          data['id']            = @id
          data['title']         = data['title'] || filename_data['title']
          data['url']           = self.permalink(data)
          data['layout']        = @ruhoh.config.posts_layout if data['layout'].nil?
          data['categories']    = Array(data['categories'])
          data['tags']          = Array(data['tags'])
          data['_type']         = type
          
          dict = {}
          dict[@id] = data
          dict
        end

        def formatted_date(date)
          Time.parse(date.to_s).strftime('%Y-%m-%d')
        rescue
          false
        end

        def parse_page_filename(filename)
          data = *filename.match(DateMatcher)
          data = *filename.match(Matcher) if data.empty?
          return {} if data.empty?

          if filename =~ DateMatcher
            {
              "path" => data[1],
              "date" => data[2],
              "slug" => data[3],
              "title" => self.to_title(data[3]),
              "extension" => data[4]
            }
          else
            {
              "path" => data[1],
              "slug" => data[2],
              "title" => self.to_title(data[2]),
              "extension" => data[3]
            }
          end
        end

        # my-post-title ===> My Post Title
        def to_title(file_slug)
          file_slug.gsub(/[^\p{Word}+]/u, ' ').gsub(/\b\w/){$&.upcase}
        end

        # Used in the client implementation to turn a draft into a post.  
        def to_filename(data)
          File.join(@ruhoh.paths.posts, "#{Ruhoh::Urls.to_slug(data['title'])}.#{data['ext']}")
        end

        # Another blatently stolen method from Jekyll
        # The category is only the first one if multiple categories exist.
        def permalink(post)
          date = Date.parse(post['date'])
          title = Ruhoh::Urls.to_url_slug(post['title'])
          format = post['permalink'] || @ruhoh.config.posts_permalink

          if format.include?(':')
            filename = File.basename(post['id'], File.extname(post['id']))
            category = Array(post['categories'])[0]
            category = category.split('/').map {|c| Ruhoh::Urls.to_url_slug(c) }.join('/') if category

            url = {
              "year"       => date.strftime("%Y"),
              "month"      => date.strftime("%m"),
              "day"        => date.strftime("%d"),
              "title"      => title,
              "filename"   => filename,
              "i_day"      => date.strftime("%d").to_i.to_s,
              "i_month"    => date.strftime("%m").to_i.to_s,
              "categories" => category || '',
            }.inject(format) { |result, token|
              result.gsub(/:#{Regexp.escape token.first}/, token.last)
            }.gsub(/\/+/, "/")
          else
            # Use the literal permalink if it is a non-tokenized string.
            url = format.gsub(/^\//, '').split('/').map {|p| CGI::escape(p) }.join('/')
          end  

          @ruhoh.to_url(url)
        end

      end

    end
  end
end