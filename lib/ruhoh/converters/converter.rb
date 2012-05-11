class Ruhoh
  module Converter
    
    def self.convert(page)
      extension = File.extname(page.data['id']).downcase
      
      Ruhoh::Converter.constants.each {|c|
        converter = Ruhoh::Converter.const_get(c)
        next unless converter.respond_to?(:convert)
        next unless converter.respond_to?(:extensions)
        next unless Array(converter.extensions).include?(extension) 
        return converter.convert(page)
      }

      page.content
    end
    
  end #Converter
end #Ruhoh