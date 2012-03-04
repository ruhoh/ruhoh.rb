class Ruhoh
  
  module Pages
    
    # Public: Generate the Pages dictionary.
    #
    def self.generate
      raise "Ruhoh.config cannot be nil.\n To set config call: Ruhoh.setup" unless Ruhoh.config
      puts "=> Generating Pages..."

      invalid_pages = []
      dictionary = {}
      total_pages = 0
      FileUtils.cd(Ruhoh.paths.site_source) {
        Dir.glob("**/*.*") { |filename| 
          next unless self.is_valid_page?(filename)
          total_pages += 1

          File.open(filename) do |page|
            front_matter = page.read.match(Ruhoh::Utils::FMregex)
            if !front_matter
              invalid_pages << filename ; next
            end

            data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
            data['id'] = filename
            data['url'] = self.permalink(data)
            data['title'] = data['title'] || self.titleize(filename)

            dictionary[filename] = data
          end
        }
      }

      if invalid_pages.empty?
        puts "=> #{total_pages - invalid_pages.count }/#{total_pages} pages processed."
      else
        puts "=> Invalid pages not processed:"
        puts invalid_pages.to_yaml
      end   
      
      dictionary 
    end
    
    def self.is_valid_page?(filename)
      return false if FileTest.directory?(filename)
      return false if ['_', '.'].include? filename[0]
      return false if Ruhoh.filters.pages['names'].include? filename
      Ruhoh.filters.pages['regexes'].each {|regex| return false if filename =~ regex }
      true
    end
    
    def self.titleize(filename)
      File.basename( filename, File.extname(filename) ).gsub(/[\W\_]/, ' ').gsub(/\b\w/){$&.upcase}
    end
    
    def self.permalink(page)
      url = '/' + page['id'].gsub(File.extname(page['id']), '.html')
      
      # sanitize url
      url = url.split('/').reject{ |part| part =~ /^\.+$/ }.join('/')
      url
    end
    
  end # Pages
  
end #Ruhoh