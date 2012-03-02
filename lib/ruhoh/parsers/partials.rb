class Ruhoh
  
  module Partials
    
    def self.generate
      partials_manifest = JSON.parse(File.open("#{Ruhoh.paths.partials}/manifest.json").read)
      partials = {}
      FileUtils.cd(Ruhoh.paths.partials) {
        partials_manifest.each do |p|
          next unless File.exist? p['path']
          partials[p['name']] = File.open(p['path']).read
        end  
      }
      partials
    end
    
  end #Partials
  
end #Ruhoh