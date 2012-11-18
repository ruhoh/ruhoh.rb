module Ruhoh::Views

  module Tags
    # Generate the tags dictionary
    def tags
      tags_url = nil
      [@ruhoh.to_url("tags"), @ruhoh.to_url("tags.html")].each { |url|
        tags_url = url and break if @ruhoh.db.routes.key?(url)
      }
      dict = {}
      @ruhoh.db.__send__(resource_name).each_value do |resource|
        Array(resource['tags']).each do |tag|
          if dict[tag]
            dict[tag]['count'] += 1
          else
            dict[tag] = { 
              'count' => 1, 
              'name' => tag,
              resource_name => [],
              'url' => "#{tags_url}##{tag}-ref"
            }
          end 

          dict[tag][resource_name] << resource['id']
        end
      end  
      dict["all"] = dict.each_value.map { |tag| tag }
      dict
    end
    
    # Convert single or Array of tag ids (names) to tag hash(es).
    def to_tags(sub_context)
      Array(sub_context).map { |id|
        tags[id] 
      }.compact
    end
  end
  
  module Categories
    # Category dictionary
    def categories
      categories_url = nil
      [@ruhoh.to_url("categories"), @ruhoh.to_url("categories.html")].each { |url|
        categories_url = url and break if @ruhoh.db.routes.key?(url)
      }
      dict = {}
      @ruhoh.db.__send__(resource_name).each_value do |resource|
        Array(resource['categories']).each do |cat|
          cat = Array(cat).join('/')
          if dict[cat]
            dict[cat]['count'] += 1
          else
            dict[cat] = { 
              'count' => 1, 
              'name' => cat, 
              resource_name => [],
              'url' => "#{categories_url}##{cat}-ref"
            }
          end 

          dict[cat][resource_name] << resource['id']
        end
      end  
      dict["all"] = dict.each_value.map { |cat| cat }
      dict
    end
          
    # Convert single or Array of category ids (names) to category hash(es).
    def to_categories(sub_context)
      Array(sub_context).map { |id|
        categories[id] 
      }.compact
    end
  end
  
  module PageHelpers
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
    
  end
end