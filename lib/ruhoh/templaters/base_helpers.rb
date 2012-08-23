class Ruhoh
  module Templaters
    module BaseHelpers
      
      def partial(name)
        p = Ruhoh::DB.partials[name.to_s]
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
        
        content = content.lines.to_a[0, line_breakpoint].join
        content = self.render(content)
        Ruhoh::Converter.convert(content, id)
      end
      
      def pages
        pages = []
        self.context['db']['pages'].each_value {|page| pages << page }
        self.mark_active_page(pages)
      end
      
      def posts
        self.to_posts(self.context['db']['posts']['chronological'])
      end
      
      def posts_latest
        latest = self.context['site']['config']['posts']['latest'].to_i rescue nil
        latest ||= 10
        (latest.to_i > 0) ? self.posts[0, latest.to_i] : self.posts
      end
      
      def categories
        cats = []
        self.context['db']['posts']['categories'].each_value { |cat| cats << cat }
        cats
      end
      
      def tags
        tags = []
        self.context['db']['posts']['tags'].each_value { |tag| tags << tag }
        tags
      end
      
      def raw_code(sub_context)
        code = sub_context.gsub('{', '&#123;').gsub('}', '&#125;').gsub('<', '&lt;').gsub('>', '&gt;')
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

      def to_posts(sub_context)
        Array(sub_context).map { |id|
          self.context['db']['posts']['dictionary'][id]
        }.compact
      end

      def to_pages(sub_context)
        pages = Array(sub_context).map { |id|
          self.context['db']['pages'][id]
        }.compact
        self.mark_active_page(pages)
      end
      
      def to_categories(sub_context)
        Array(sub_context).map { |id|
          self.context['db']['posts']['categories'][id] 
        }.compact
      end
      
      def to_tags(sub_context)
        Array(sub_context).map { |id|
          self.context['db']['posts']['tags'][id] 
        }.compact
      end
      
      def next(sub_context)
        return unless sub_context.is_a?(String) || sub_context.is_a?(Hash)
        id = sub_context.is_a?(Hash) ? sub_context['id'] : sub_context
        return unless id
        index = self.context['db']['posts']['chronological'].index(id)
        return unless index && (index-1 >= 0)
        next_id = self.context['db']['posts']['chronological'][index-1]
        return unless next_id
        self.to_posts(next_id)
      end
      
      def previous(sub_context)
        return unless sub_context.is_a?(String) || sub_context.is_a?(Hash)
        id = sub_context.is_a?(Hash) ? sub_context['id'] : sub_context
        return unless id
        index = self.context['db']['posts']['chronological'].index(id)
        return unless index && (index+1 >= 0)
        prev_id = self.context['db']['posts']['chronological'][index+1]
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