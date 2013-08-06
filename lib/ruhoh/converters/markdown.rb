require "redcarpet"

module Redcarpet
  module RenderHTML5
    # use html5-compliant figures instead of simple images
    # ![Alt text](/path/to/img.jpg "Optional title")
    class WithFigures < Redcarpet::Render::HTML
      def image(link, title, alt)
        "<figure><img src='#{link}' alt='#{alt}' /><figcaption><p>#{title}</p></figcaption></figure>"
      end
    end
  end
end

class Ruhoh
  module Converter
    module Markdown

      def self.extensions
        ['.md', '.markdown']
      end
      
      def self.convert(content)
        require 'redcarpet'
        markdown = Redcarpet::Markdown.new(Redcarpet::RenderHTML5::WithFigures.new(:with_toc_data => true, :encoding => 'UTF-8'),
          :autolink => true, 
          :fenced_code_blocks => true, 
          :encoding => 'UTF-8'
        )
        markdown.render(content)
      end
    end
  end
end