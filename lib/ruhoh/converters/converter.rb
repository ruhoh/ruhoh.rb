require 'maruku'

class Ruhoh

  module Converter
    
    def self.convert(page)
      if ['.md', '.markdown'].include? File.extname(page.data['id']).downcase
        Maruku.new(page.content).to_html
      else
        page.content
      end
    end
    
  end #Converter
  
end #Ruhoh