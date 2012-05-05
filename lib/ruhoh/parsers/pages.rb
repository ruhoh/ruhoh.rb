class Ruhoh
  module Parsers
    module Pages
    
      # Public: Generate the Pages dictionary.
      #
      def self.generate
        Ruhoh.ensure_setup

        pages = self.files
        invalid = []
        dictionary = {}

        pages.each do |filename|
          id = self.make_id(filename)
          parsed_page = ''
          FileUtils.cd(Ruhoh.paths.site_source) { parsed_page = Ruhoh::Utils.parse_file(filename) }
          if parsed_page.empty?
            error = "Invalid Yaml Front Matter.\n Ensure this page has valid YAML, even if it's empty."
            invalid << [filename, error] ; next
          end
          
          parsed_page['data']['id']     = id
          parsed_page['data']['url']    = self.permalink(parsed_page['data'])
          parsed_page['data']['title']  = parsed_page['data']['title'] || self.to_title(filename)

          dictionary[id] = parsed_page['data']
        end
          
        Ruhoh::Utils.report('Pages', dictionary, invalid)  
        dictionary 
      end

      def self.files
        FileUtils.cd(Ruhoh.paths.site_source) {
          return Dir["#{Ruhoh.folders.pages}/**/*.*"].select { |filename|
            next unless self.is_valid_page?(filename)
            true
          }
        }
      end
      
      def self.is_valid_page?(filepath)
        return false if FileTest.directory?(filepath)
        return false if ['.'].include? filepath[0]
        return false if Ruhoh.filters.pages['names'].include? filepath
        Ruhoh.filters.pages['regexes'].each {|regex| return false if filepath =~ regex }
        true
      end
    
      def self.make_id(filename)
        filename.gsub(Regexp.new("^#{Ruhoh.folders.pages}/"), '')
      end
      
      def self.to_title(filename)
        name = File.basename( filename, File.extname(filename) )
        name = filename.split('/')[-2] if name == 'index' && !filename.index('/').nil?
        name.gsub(/[\W\_]/, ' ').gsub(/\b\w/){$&.upcase}
      end
    
      # Build the permalink for the given page.
      # Only recognize 'convertable' extensions for Markdown at the moment.
      # This means 'non-convertable' extensions should pass-through.
      #
      # Returns [String] the permalink for this page.
      def self.permalink(page)
        url = '/'
        ext = File.extname(page['id'])
        url += if ['.md', '.markdown'].include?(ext)
          page['id'].gsub(Regexp.new("#{ext}$"), '.html')
        else
          page['id']
        end
        
        url = url.split('/').reject{ |part| part[0] == '.' }.join('/')
        url = url.gsub(/\/index.html$/, '')
        if page['permalink'] == 'pretty' || Ruhoh.config.pages_permalink == 'pretty'
          url = url.gsub(/\.html$/, '') 
        end
        url = "/" if url.empty?

        url
      end
    
    end # Pages
  end #Parsers
end #Ruhoh