class Ruhoh

  module Parsers
    
    module Posts
    
      MATCHER = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/

      # Public: Generate the Posts dictionary.
      #
      def self.generate
        raise "Ruhoh.config cannot be nil.\n To set config call: Ruhoh.setup" unless Ruhoh.config
        
        dictionary, invalid = self.process('drafts')
        
        ordered_posts = self.ordered_posts(dictionary)
        data = {
          'dictionary'      => dictionary,
          'chronological'   => self.build_chronology(ordered_posts),
          'collated'        => self.collate(ordered_posts),
          'tags'            => self.parse_tags(ordered_posts),
          'categories'      => self.parse_categories(ordered_posts)
        }

        report = "#{dictionary.count}/#{dictionary.count + invalid.count} posts processed."
        if dictionary.empty? && invalid.empty?
          Ruhoh::Friend.say { plain "0 posts to process." }
        elsif invalid.empty?
          Ruhoh::Friend.say { green report }
        else
          Ruhoh::Friend.say {
            yellow report
            list "Posts not processed:", invalid
          }
        end
        
        data
      end

      def self.generate_drafts
        raise "Ruhoh.config cannot be nil.\n To set config call: Ruhoh.setup" unless Ruhoh.config
        
        drafts, invalid = self.process('drafts')
        
        report = "#{drafts.count}/#{drafts.count + invalid.count} drafts processed."
        
        if drafts.empty? && invalid.empty?
          Ruhoh::Friend.say { plain "0 drafts to process." }
        elsif invalid.empty?
          Ruhoh::Friend.say { green report }
        else
          Ruhoh::Friend.say {
            yellow report
            list "Drafts not processed:", invalid
          }
        end
        
        drafts
      end
      
      def self.process(type)
        dictionary = {}
        invalid = []
        
        self.files(type).each do |filename|
          parsed_page = Ruhoh::Utils.parse_file(filename)
          if parsed_page.empty?
            error = "Invalid YAML Front Matter. Ensure this page has valid YAML, even if it's empty."
            invalid << [filename, error] ; next
          end
          data = parsed_page['data']
          
          filename_data = self.parse_filename(filename)
          if filename_data.empty?
            error = "Invalid Filename Format. Format should be: YYYY-MM-DD-my-post-title.ext"
            invalid << [filename, error] ; next
          end
          
          data['date'] ||= filename_data['date']

          begin 
            Time.parse(data['date'])
          rescue
            error = "Invalid Date Format. Date should be: YYYY/MM/DD"
            invalid << [filename, error] ; next
          end
        
          data['id']            = filename
          data['title']         = data['title'] || self.titleize(filename_data['slug'])
          data['url']           = self.permalink(data)
          dictionary[filename]  = data
        end
        
        [dictionary, invalid]
      end
      
      def self.files(type)
        FileUtils.cd(Ruhoh.paths.site_source) {
          return Dir["#{Ruhoh.folders.__send__(type)}/**/*.*"].select { |filename|
            next if FileTest.directory?(filename)
            next if ['.'].include? filename[0]
            true
          }
        }
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
        data = *filename.match(MATCHER)
        return {} if data.empty?
        {
          "path" => data[1],
          "date" => data[2],
          "slug" => data[3],
          "extension" => data[4]
        }
      end
      
      # my-post-title ===> My Post Title
      def self.titleize(file_slug)
        file_slug.gsub(/[\W\_]/, ' ').gsub(/\b\w/){$&.upcase}
      end
    
      # Another blatently stolen method from Jekyll
      def self.permalink(post)
        date = Date.parse(post['date'])
        title = post['title'].downcase.gsub(' ', '-').gsub('.','')
        format = post['permalink'] || Ruhoh.config.permalink  || "/:categories/:year/:month/:day/:title.html"
        
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
              tags[tag] = { 'count' => 1, 'name' => tag, 'posts' => [] }
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
              categories[cat] = { 'count' => 1, 'name' => cat, 'posts' => [] }
            end 

            categories[cat]['posts'] << post['id']
          end
        end  
        categories
      end

    end # Post
  
  end #Parsers
  
end #Ruhoh