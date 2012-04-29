class Ruhoh
  module Parsers
    module Layouts

      # Generate layouts only from the active theme.
      def self.generate
        layouts = {}
        invalid = []
        self.files.each do |filename|
          id = File.basename(filename, File.extname(filename))
          layouts[id] = Ruhoh::Utils.parse_file(Ruhoh.paths.layouts, filename)

          if layouts[id].empty?
            error = "Invalid YAML Front Matter. Ensure this page has valid YAML, even if it's empty."
            invalid << [filename, error]
          end
        end
        
        Ruhoh::Utils.report('Layouts', layouts, invalid)
        layouts
      end

      def self.files
        FileUtils.cd(Ruhoh.paths.layouts) {
          return Dir["**/*.*"].select { |filename|
            next if FileTest.directory?(filename)
            next if ['_','.'].include? filename[0]
            true
          }
        }
      end
      
      
    end #Layouts
  end #Parsers
end #Ruhoh