module Ruhoh::Resources::Page
  class ModelView < Ruhoh::Resources::Base::ModelView
    
    # Default order by alphabetical title name.
    def <=>(other)
      title <=> other.title
    end
    
    def categories
      collection.to_categories(super)
    end

    def tags
      collection.to_tags(super)
    end

    # Lazy-load the page body.
    # Notes:
    # @content is not used for caching, it's used to manually
    # define content for a given page. Useful in the case that
    # you want to model a resource that does not actually
    # reference a file.
    def content
      return @content if @content
      content, id = self.get_page_content
      content = master.render(content)
      Ruhoh::Converter.convert(content, id)
    end

    def get_page_content
      content = @ruhoh.db.content(pointer)
      [content, id]
    end
    
    def is_active_page
      id == master.page_data['id']
    end
    
    # Truncate the page content relative to a line_count limit.
    # This is optimized for markdown files in which content is largely
    # blocked into chunks and separating by blank lines.
    # The line_limit truncates content based on # of content-based lines,
    # so blank lines don't count toward the limit.
    # Always break the content on a blank line only so result stays formatted nicely.
    def summary
      resource = pointer["resource"]
      content, id = self.get_page_content
      line_limit = @ruhoh.db.config(resource)['summary_lines']
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
      content.lines.to_enum.with_index(line_breakpoint) do |line, i|
        # Add lines containing destination urls.
        if line =~ /^\[[^\]]+\]:/
          summary << "\n#{line}"
        end
      end

      summary = master.render(summary)
      Ruhoh::Converter.convert(summary, id)
    end

    def next
      return unless id
      all_cache = collection.all
      index = all_cache.index {|p| p["id"] == id}
      return unless index && (index-1 >= 0)
      _next = all_cache[index-1]
      return unless _next
      _next
    end

    def previous
      return unless id
      all_cache = collection.all
      index = all_cache.index {|p| p["id"] == id}
      return unless index && (index+1 >= 0)
      prev = all_cache[index+1]
      return unless prev
      prev
    end

  end
end