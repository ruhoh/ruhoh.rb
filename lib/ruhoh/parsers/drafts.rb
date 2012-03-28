class Ruhoh
  module Parsers
    module Drafts
      
      def self.generate
        raise "Ruhoh.config cannot be nil.\n To set config call: Ruhoh.setup" unless Ruhoh.config
        
        dictionary = {}
        invalid = []
        
        self.files.each do |filename|
          parsed_page = Ruhoh::Utils.parse_file(filename)
          if parsed_page.empty?
            error = "Invalid YAML Front Matter. Ensure this page has valid YAML, even if it's empty."
            invalid << [filename, error] ; next
          end

          data                  = parsed_page['data']
          data['id']            = filename
          data['url']           = "/#{filename}"
          dictionary[filename]  = data
        end
        
        self.report(dictionary, invalid)
        dictionary
      end
      
      def self.files
        FileUtils.cd(Ruhoh.paths.site_source) {
          return Dir["#{Ruhoh.folders.drafts}/**/*.*"].select { |filename|
            next if FileTest.directory?(filename)
            next if ['.'].include? filename[0]
            true
          }
        }
      end
      
      def self.report(dictionary, invalid)
        output = "#{dictionary.count}/#{dictionary.count + invalid.count} drafts processed."
        if dictionary.empty? && invalid.empty?
          Ruhoh::Friend.say { plain "0 drafts to process." }
        elsif invalid.empty?
          Ruhoh::Friend.say { green output }
        else
          Ruhoh::Friend.say {
            yellow output
            list "Drafts not processed:", invalid
          }
        end
      end
      
    end #Drafts
  end #Parsers
end #Ruhoh