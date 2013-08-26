require 'nokogiri'
class Ruhoh
  class Summarizer
    SummaryNodeClassName = 'summary'
    Headings = Nokogiri::HTML::ElementDescription::HEADING + %w{ header hgroup }

    def initialize(opts)
      @content = opts[:content] ; opts.delete(:content)
      @opts = opts
    end

    # Generate a truncated summary.
    # - If a summary element (`<tag class="summary">...</tag>`) is specified
    #   in the content, return it.
    # - If summary_lines > 0, truncate after the first complete element where
    #   the number of summary lines is greater than summary_lines.
    # - If @opts[:stop_at_header] is a number n, stop before the nth header.
    # - If @opts[:stop_at_header] is true, stop before the first header after
    #   content has been included. In other words, don't count headers at the
    #   top of the page.
    def generate
      content_doc = Nokogiri::HTML.fragment(@content)

      # Return a summary element if specified
      summary_el = content_doc.at_css('.' + SummaryNodeClassName)
      return summary_el.to_html if summary_el

      # Create the summary element.
      summary_doc = Nokogiri::XML::Node.new("div", Nokogiri::HTML::Document.new)
      summary_doc["class"] = SummaryNodeClassName

      content_doc.children.each do |node|

        if @opts[:stop_at_header] == true
          # Detect first header after content
          if not (Headings.include?(node.name) && node.content.empty?)
            @opts[:stop_at_header] = 1
          end
        elsif @opts[:stop_at_header].is_a?(Integer) && Headings.include?(node.name)
          if @opts[:stop_at_header] > 1
            @opts[:stop_at_header] -= 1;
          else
            summary_doc["class"] += " ellipsis"
            break
          end
        end

        if @opts[:line_limit] > 0 && summary_doc.content.lines.to_a.length > @opts[:line_limit]
          # Skip through leftover whitespace. Without this check, the summary
          # can be marked as ellipsis even if it isn't.
          unless node.text? && node.text.strip.empty?
            summary_doc["class"] += " ellipsis"
            break
          else
            next
          end
        end

        summary_doc << node
      end

      summary_doc.to_html
    end
  end
end