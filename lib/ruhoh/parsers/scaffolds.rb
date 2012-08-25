class Ruhoh
  module Parsers
    module Scaffolds
    
      def self.generate
        self.system_scaffolds.merge(
          self.scaffolds
        )
      end
      
      def self.scaffolds
        self.process(Ruhoh.paths.scaffolds)
      end

      def self.system_scaffolds
        self.process(Ruhoh.paths.system_scaffolds)
      end
      
      def self.process(path)
        return {} unless File.exist?(path)
      
        scaffolds = {}
        FileUtils.cd(path) {
          Dir.glob("**/*").each { |filename|
            next if FileTest.directory?(filename)
            next if ['.'].include? filename[0]
            File.open(filename, 'r:UTF-8') { |f| scaffolds[filename] = f.read }
          }
        }
        scaffolds
      end
    
    end #Scaffolds
  end #Parsers
end #Ruhoh