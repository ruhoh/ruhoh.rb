class Ruhoh
  module Parsers
    module Layouts

      # Generate layouts only from the active theme.
      def self.generate
        layouts = {}
        self.files.each do |filename|
          id = File.basename(filename, File.extname(filename))
          data = Ruhoh::Utils.parse_file(Ruhoh.paths.theme_layouts, filename)
          data['id'] = id
          layouts[id] = data
        end
        
        Ruhoh::Utils.report('Layouts', layouts, [])
        layouts
      end

      def self.files
        FileUtils.cd(Ruhoh.paths.theme_layouts) {
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