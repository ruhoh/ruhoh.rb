class Ruhoh

  module Parsers
    
    module Partials
    
      def self.generate
        self.system_partials.merge(self.global_partials).merge(self.theme_partials)
      end

      def self.theme_partials
        self.process(Ruhoh.paths.partials)
      end
      
      def self.global_partials
        self.process(Ruhoh.paths.global_partials)
      end

      def self.system_partials
        self.process(File.join(Ruhoh::Root, 'system_partials'))
      end

      def self.process(path)
        return {} unless File.exist?(path)
      
        partials = {}
        FileUtils.cd(path) {
          Dir.glob("**/*").each { |filename|
            next if FileTest.directory?(filename)
            next if ['.'].include? filename[0]
            File.open(filename) { |f| partials[filename] = f.read }
          }
        }
        partials
      end
    
    end #Partials
  
  end #Parsers
  
end #Ruhoh