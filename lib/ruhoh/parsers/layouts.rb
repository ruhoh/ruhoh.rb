class Ruhoh
  
  module Layouts

    # Generate layouts only from the active theme.
    def self.generate
      layouts = {}
      FileUtils.cd(Ruhoh.paths.layouts) {
        Dir.glob("**/*.*") { |filename|
          next if FileTest.directory?(filename)
          next if ['_','.'].include? filename[0]
          id = File.basename(filename, File.extname(filename))
          layouts[id] = Ruhoh::Utils.parse_file(Ruhoh.paths.layouts, filename)
        }
      }
      layouts
    end

  end #Layouts
  
end #Ruhoh