require 'ruhoh/views/helpers/categories'
require 'ruhoh/views/helpers/tags'

module Ruhoh::Views::Helpers
  module Page
    include Tags
    include Categories

    # if loaded as a page we need to namespace and delegate to self
    def page
      self
    end
    
    # Lazy-load the page body.
    # When in a global scope (layouts, pages), the content is for the current page.
    # May also be called in sub-contexts such as looping through resources.
    #
    #  {{# posts }}
    #    {{{ content }}}
    #  {{/ posts }}
    def content
      content, id = self.get_page_content
      content = self.render(content)
      Ruhoh::Converter.convert(content, id)
    end
    
    def get_page_content
      data = self.context['id'] ? self.context : self.context['page']
      return '' unless data['id']
      page = @ruhoh.page(data['pointer'])
      [page.content, data['id']]
    end
    
    # Truncate the page content relative to a line_count limit.
    # This is optimized for markdown files in which content is largely
    # blocked into chunks and separating by blank lines.
    # The line_limit truncates content based on # of content-based lines,
    # so blank lines don't count toward the limit.
    # Always break the content on a blank line only so result stays formatted nicely.
    def summary
      parser = context["pointer"]["parser"]
      content, id = self.get_page_content
      line_limit = @ruhoh.db.config(parser)['summary_lines']
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
    
    def next
      id = context["id"]
      return unless id
      all_cache = all
      index = all_cache.index {|p| p["id"] == id}
      return unless index && (index-1 >= 0)
      _next = all_cache[index-1]
      return unless _next
      _next
    end
    
    def previous
      id = context["id"]
      return unless id
      all_cache = all
      index = all_cache.index {|p| p["id"] == id}
      return unless index && (index+1 >= 0)
      prev = self.all[index+1]
      return unless prev
      prev
    end
    
    # Marks the active page if exists in the given pages Array
    def mark_active_page(pages)
      pages.each_with_index do |page, i| 
        next unless context["page"] && (page['id'] == context["page"]['id'])
        active_page = page.dup
        active_page['is_active_page'] = true
        pages[i] = active_page
      end
      pages
    end
    
    # current_page is set via a compiler or previewer
    # in which it can discern what current_page to serve
    def paginator
      per_page = @ruhoh.db.config("paginator")["per_page"]
      current_page = self.context["page"]['current_page'].to_i rescue 0
      current_page = current_page.zero? ? 1 : current_page
      offset = (current_page-1)*per_page

      post_batch = all[offset, per_page]
      raise "Page does not exist" unless post_batch
      post_batch
    end
  
    def paginator_navigation
      config = @ruhoh.db.config("paginator")
      post_count = @ruhoh.db.posts.length
      total_pages = (post_count.to_f/config["per_page"]).ceil
      current_page = self.context["page"]['current_page'].to_i rescue 0
      current_page = current_page.zero? ? 1 : current_page
    
      pages = total_pages.times.map { |i| 
        {
          "url" => (i.zero? ? config["root_page"] : "#{config["namespace"]}#{i+1}"),
          "name" => "#{i+1}",
          "is_active_page" => (i+1 == current_page)
        }
      }
      pages 
    end
  end
end