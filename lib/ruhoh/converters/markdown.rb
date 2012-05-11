class Ruhoh
  module Converter
    module Markdown

      def self.extensions
        ['.md', '.markdown']
      end
      
      def self.convert(page)
        require 'redcarpet'
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(:with_toc_data => true),
          :autolink => true, 
          :fenced_code_blocks => true, 
        )
        markdown.render(page.content)
      end
    end
  end
end