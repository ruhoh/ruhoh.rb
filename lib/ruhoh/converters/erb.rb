class Ruhoh
  module Converter
    # Erb converter is needed so this extension is rendered to .html.
    # Actual Erb rendering is handled by the view_renderer
    module Erb
      def self.extensions
        ['.erb']
      end

      def self.convert(content)
        content
      end
    end
  end
end
