class Ruhoh
  module Converter
    module Markdown

      def self.extensions
        ['.md', '.markdown']
      end
      
      def self.convert(page)
        require 'maruku'
        Maruku.new(page.content).to_html
      end
    end
  end
end