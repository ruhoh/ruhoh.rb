class Ruhoh
  module Parsers
    module Pages
    
      # Public: Generate the Pages dictionary.
      #
      def self.generate
        Ruhoh.ensure_setup

        pages = self.files
        dictionary = {}

        pages.each do |filename|
          id = self.make_id(filename)
          parsed_page = ''
          FileUtils.cd(Ruhoh.paths.base) { parsed_page = Ruhoh::Utils.parse_page_file(filename) }
          
          parsed_page['data']['id']     = id
          parsed_page['data']['url']    = self.permalink(parsed_page['data'])
          parsed_page['data']['title']  = parsed_page['data']['title'] || self.to_title(filename)
          if parsed_page['data']['layout'].nil?
            parsed_page['data']['layout'] = Ruhoh.config.pages_layout
          end
          
          dictionary[id] = parsed_page['data']
        end
          
        Ruhoh::Utils.report('Pages', dictionary, [])  
        dictionary 
      end

      def self.files
        FileUtils.cd(Ruhoh.paths.base) {
          return Dir["#{Ruhoh.names.pages}/**/*.*"].select { |filename|
            next unless self.is_valid_page?(filename)
            true
          }
        }
      end
      
      def self.is_valid_page?(filepath)
        return false if FileTest.directory?(filepath)
        return false if ['.'].include? filepath[0]
        Ruhoh.config.pages_exclude.each {|regex| return false if filepath =~ regex }
        true
      end
    
      def self.make_id(filename)
        filename.gsub(Regexp.new("^#{Ruhoh.names.pages}/"), '')
      end
      
      def self.to_title(filename)
        name = File.basename( filename, File.extname(filename) )
        name = filename.split('/')[-2] if name == 'index' && !filename.index('/').nil?
        name.gsub(/[^\p{Word}+]/u, ' ').gsub(/\b\w/){$&.upcase}
      end
    
      # Build the permalink for the given page.
      # Only recognize extensions registered from a 'convertable' module.
      # This means 'non-convertable' extensions should pass-through.
      #
      # Returns [String] the permalink for this page.
      def self.permalink(page)
        ext = File.extname(page['id'])
        name = page['id'].gsub(Regexp.new("#{ext}$"), '')
        ext = '.html' if Ruhoh::Converter.extensions.include?(ext)
        url = name.split('/').map {|p| Ruhoh::Urls.to_url_slug(p) }.join('/')
        url = "#{url}#{ext}".gsub(/index.html$/, '')
        if page['permalink'] == 'pretty' || Ruhoh.config.pages_permalink == 'pretty'
          url = url.gsub(/\.html$/, '')
        end
        
        url = '/' if url.empty?
        Ruhoh::Urls.to_url(url)
      end
    
    end # Pages
  end #Parsers
end #Ruhoh