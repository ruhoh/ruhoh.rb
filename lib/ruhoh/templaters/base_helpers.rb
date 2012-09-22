class Ruhoh
  module Templaters
    module BaseHelpers
      
      def partial(name)
        p = @ruhoh.db.partials[name.to_s]
        Ruhoh::Friend.say { yellow "partial not found: '#{name}'" } if p.nil?
        p
      end
      
      # Truncate the page content relative to a line_count limit.
      # This is optimized for markdown files in which content is largely
      # blocked into chunks and separating by blank lines.
      # The line_limit truncates content based on # of content-based lines,
      # so blank lines don't count toward the limit.
      # Always break the content on a blank line only so result stays formatted nicely.
      def summary
        content, id = self.get_page_content
        line_limit = self.context['site']['config']['posts']['summary_lines'].to_i rescue nil
        line_limit ||= 20
        line_count = 0
        line_breakpoint = content.lines.count

        content.lines.each_with_index do |line, i|
          if line =~ /^\s*$/  # line with only whitespace
            if line_count >= line_limit
              line_breakpoint = i
              break
            end
          else
            line_count += 1
          end
        end

        summary = content.lines.to_a[0, line_breakpoint].join

        # The summary may be missing some key items needed to render properly.
        # So search the rest of the content and add it to the summary.
        content.lines.with_index(line_breakpoint) do |line, i|
          # Add lines containing destination urls.
          if line =~ /^\[[^\]]+\]:/
            summary << "\n#{line}"
          end
        end

        summary = self.render(summary)
        Ruhoh::Converter.convert(summary, id)
      end
      
      def pages
        pages = []
        @ruhoh.db.pages.each_value {|page| pages << page }
        self.mark_active_page(pages)
      end
      
      def raw_code(sub_context)
        code = sub_context.gsub('{', '&#123;').gsub('}', '&#125;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('_', "&#95;")
        "<pre><code>#{code}</code></pre>"
      end
      
      def debug(sub_context)
        Ruhoh::Friend.say { 
          yellow "?debug:"
          magenta sub_context.class
          cyan sub_context.inspect
        }
        
        "<pre>#{sub_context.class}\n#{sub_context.pretty_inspect}</pre>"
      end

      def to_pages(sub_context)
        pages = Array(sub_context).map { |id|
          @ruhoh.db.pages[id]
        }.compact
        self.mark_active_page(pages)
      end
      
      def next(sub_context)
        return unless sub_context.is_a?(String) || sub_context.is_a?(Hash)
        id = sub_context.is_a?(Hash) ? sub_context['id'] : sub_context
        return unless id
        index = self.posts.index(id)
        return unless index && (index-1 >= 0)
        next_id = self.posts[index-1]
        return unless next_id
        self.to_posts(next_id)
      end
      
      def previous(sub_context)
        return unless sub_context.is_a?(String) || sub_context.is_a?(Hash)
        id = sub_context.is_a?(Hash) ? sub_context['id'] : sub_context
        return unless id
        index = self.posts.index(id)
        return unless index && (index+1 >= 0)
        prev_id = self.posts[index+1]
        return unless prev_id
        self.to_posts(prev_id)
      end
      
      def to_json(sub_context)
        sub_context.to_json
      end
            
      # Marks the active page if exists in the given pages Array
      def mark_active_page(pages)
        pages.each_with_index do |page, i| 
          next unless page['id'] == self.context[:page]['id']
          active_page = page.dup
          active_page['is_active_page'] = true
          pages[i] = active_page
        end
        pages
      end
      
    end #BaseHelpers
  end #Templaters
end #Ruhoh