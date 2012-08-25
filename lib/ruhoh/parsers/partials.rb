class Ruhoh
  module Parsers
    module Partials
    
      def self.generate
        self.system_partials.merge(
          self.global_partials
        ).merge(
          self.theme_partials
        )
      end
      
      def self.theme_partials
        self.process(Ruhoh.paths.theme_partials)
      end
      
      def self.global_partials
        self.process(Ruhoh.paths.partials)
      end

      def self.system_partials
        self.process(Ruhoh.paths.system_partials)
      end
      
      def self.process(path)
        return {} unless File.exist?(path)
      
        partials = {}
        FileUtils.cd(path) {
          Dir.glob("**/*").each { |filename|
            next if FileTest.directory?(filename)
            next if ['.'].include? filename[0]
            name = filename.chomp(File.extname(filename))
            File.open(filename, 'r:UTF-8') { |f| partials[name] = f.read }
          }
        }
        partials
      end
    
    end #Partials
  end #Parsers
end #Ruhoh