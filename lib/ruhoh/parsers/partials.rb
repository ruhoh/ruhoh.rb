class Ruhoh
  
  module Partials
    
    def self.generate
      partials_path = './_client/partials'
      partials_manifest = JSON.parse(File.open("#{partials_path}/manifest.json").read)
      partials = {}
      FileUtils.cd(partials_path) {
        partials_manifest.each do |p|
          next unless File.exist? p['path']
          partials[p['name']] = File.open(p['path']).read
        end  
      }
      partials
    end
    
  end #Partials
  
end #Ruhoh