class Ruhoh
  module Converter
    module Textile

      def self.extensions
        ['.textile']
      end
      
      def self.convert(content)
        require 'redcloth'
        RedCloth.new(content).to_html
      end
    end
  end
end
