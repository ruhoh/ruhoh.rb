require 'maruku'

class Ruhoh

  module Converter
    
    MarkdownExtensions = ['.md', '.markdown']
    TextileExtensions = ['.textile']
    
    def self.convert(page)
      self.__send__ self.which_converter(page.data['id']), page
    end
    
    def self.which_converter(filename)
      extension = File.extname(filename).downcase

      if MarkdownExtensions.include? extension
        :markdown
      elsif TextileExtensions.include? extension
        :textile
      else
        :none
      end
    end
    
    # Markdown
    def self.markdown(page)
      Maruku.new(page.content).to_html
    end
    
    # Textile
    # sample implementation
    def self.textile(page)
      'textile not supported yet =('
    end
    
    # No converter
    def self.none(page)
      page.content
    end
    
  end #Converter
  
end #Ruhoh