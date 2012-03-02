class Ruhoh
  
  module Layouts

    # Generate layouts only from the active theme.
    def self.generate
      layouts = {}
      FileUtils.cd(File.join(Ruhoh.config.site_source_path, Ruhoh.config.theme_path, 'layouts')) {
        Dir.glob("**/*.*") { |filename|
          next if FileTest.directory?(filename)
          next if ['_','.'].include? filename[0]
          id = File.basename(filename, File.extname(filename))
          layouts[id] = Ruhoh::Utils.parse_file(Ruhoh.config.theme_path, 'layouts', filename)
        }
      }
      layouts
    end

  end #Layouts
  
end #Ruhoh