class Ruhoh
  module Parsers
    module Posts
    
      DateMatcher = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/
      Matcher = /^(.+\/)*(.*)(\.[^.]+)$/

      # Public: Generate the Posts dictionary.
      #
      def self.generate
        Ruhoh.ensure_setup
        
        results = self.process
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
      
      def self.process
        dictionary = {}
        drafts = []
        invalid = []

        self.files.each do |filename|
          parsed_page = ''
          FileUtils.cd(Ruhoh.paths.site_source) { parsed_page = Ruhoh::Utils.parse_file(filename) }
          data = parsed_page['data']
          
          filename_data = self.parse_filename(filename)
          if filename_data.empty?
            error = "Invalid Filename Format. Format should be: my-post-title.ext"
            invalid << [filename, error] ; next
          end
          
          data['date'] ||= filename_data['date']

          unless self.formatted_date(data['date'])
            error = "Invalid Date Format. Date should be: YYYY-MM-DD"
            invalid << [filename, error] ; next
          end

          if data['type'] == 'draft'
            next if Ruhoh.config.env == 'production'
            drafts << filename 
          end  
          
          data['date']          = data['date'].to_s
          data['id']            = filename
          data['title']         = data['title'] || filename_data['title']
          data['url']           = self.permalink(data)
          data['layout']        = Ruhoh.config.posts.layout if data['layout'].nil?
          dictionary[filename]  = data
        end
        
        Ruhoh::Utils.report('Posts', dictionary, invalid)
        
        { 
          "posts" => dictionary,
          "drafts" => drafts
        }
      end
      
      def self.formatted_date(date)
        Time.parse(date.to_s).strftime('%Y-%m-%d')
      rescue
        false
      end
      
      def self.files
        FileUtils.cd(Ruhoh.paths.site_source) {
          return Dir["#{Ruhoh.folders.posts}/**/*.*"].select { |filename|
            next unless self.is_valid_page?(filename)
            true
          }
        }
      end
      
      def self.is_valid_page?(filepath)
        return false if FileTest.directory?(filepath)
        return false if ['.'].include? filepath[0]
        Ruhoh.filters.posts.each {|regex| return false if filepath =~ regex }
        true
      end
      
      def self.ordered_posts(dictionary)
        ordered_posts = []
        dictionary.each_value { |val| ordered_posts << val }
        ordered_posts.sort! {
          |a,b| Date.parse(b['date']) <=> Date.parse(a['date'])
        }

        ordered_posts
      end
      
      def self.parse_filename(filename)
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
      def self.to_title(file_slug)
        file_slug.gsub(/[\W\_]/, ' ').gsub(/\b\w/){$&.upcase}
      end
    
      # My Post Title ===> my-post-title
      def self.to_slug(title)
        title.downcase.strip.gsub(/\s/, '-').gsub(/[^\w-]/, '')
      end
        
      # Used in the client implementation to turn a draft into a post.  
      def self.to_filename(data)
        File.join(Ruhoh.paths.posts, "#{self.to_slug(data['title'])}.#{data['ext']}")
      end
      
      # Another blatently stolen method from Jekyll
      def self.permalink(post)
        date = Date.parse(post['date'])
        title = post['title'].downcase.gsub(' ', '-').gsub('.','')
        format = post['permalink'] || Ruhoh.config.posts.permalink  || "/:categories/:year/:month/:day/:title.html"
        
        url = {
          "year"       => date.strftime("%Y"),
          "month"      => date.strftime("%m"),
          "day"        => date.strftime("%d"),
          "title"      => CGI::escape(title),
          "i_day"      => date.strftime("%d").to_i.to_s,
          "i_month"    => date.strftime("%m").to_i.to_s,
          "categories" => Array(post['categories'])[0] || '',
          "output_ext" => 'html' # what's this for?
        }.inject(format) { |result, token|
          result.gsub(/:#{Regexp.escape token.first}/, token.last)
        }.gsub(/\/\//, "/")

        # sanitize url
        url = url.split('/').reject{ |part| part =~ /^\.+$/ }.join('/')
        url += "/" if url =~ /\/$/
        url
      end
    
      def self.build_chronology(ordered_posts)
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
      def self.collate(ordered_posts)
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

      def self.parse_tags(ordered_posts)
        tags = {}
  
        ordered_posts.each do |post|
          Array(post['tags']).each do |tag|
            if tags[tag]
              tags[tag]['count'] += 1
            else
              tags[tag] = { 
                'count' => 1, 
                'name' => tag,
                'url'  => "/tags.html##{tag}-ref",
                'posts' => [] 
              }
            end 

            tags[tag]['posts'] << post['id']
          end
        end  
        tags
      end

      def self.parse_categories(ordered_posts)
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
                'url'  => "/categories.html##{cat}-ref",
                'posts' => []
              }
            end 

            categories[cat]['posts'] << post['id']
          end
        end  
        categories
      end

    end # Post
  end #Parsers
end #Ruhoh