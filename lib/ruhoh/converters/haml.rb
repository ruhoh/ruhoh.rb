class Ruhoh
  module Converter
    # Haml converter is needed so this extension is rendered to .html.
    # Actual Haml rendering is handled by the view_renderer
    module Haml
      def self.extensions
        ['.haml']
      end

      def self.convert(content)
        content
      end
    end
  end
end
