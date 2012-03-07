class Ruhoh

  module Parsers
    
    module Partials
    
      def self.generate
        self.process(Ruhoh.paths.global_partials).merge( self.process(Ruhoh.paths.partials) )
      end

      def self.process(path)
        return {} unless File.exist?(path)
      
        partials = {}
        FileUtils.cd(path) {
          Dir.glob("**/*").each { |filename|
            next if FileTest.directory?(filename)
            next if ['.'].include? filename[0]
            partials[filename] = File.open(filename).read
          }
        }
        partials
      end
    
    end #Partials
  
  end #Parsers
  
end #Ruhoh