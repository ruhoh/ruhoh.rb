require 'ruhoh/views/helpers/categories'
require 'ruhoh/views/helpers/tags'
require 'ostruct'

module Ruhoh::Views::Helpers
  module Page
    
    class View < Ruhoh::Views::RMustache
      include Tags
      include Categories

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

      # Model a single instance of a Page object
      class Single < OpenStruct
        attr_accessor :collection
        attr_accessor :master

        def initialize(ruhoh, data={})
          @ruhoh = ruhoh
          super(data) if data.is_a?(Hash)
        end

        def [](attribute)
          __send__(attribute)
        end

        def categories
          collection.to_categories(super)
        end

        def tags
          collection.to_tags(super)
        end

        # Lazy-load the page body.
        # When in a global scope (layouts, pages), the content is for the current page.
        # May also be called in sub-contexts such as looping through resources.
        #
        #  {{# posts }}
        #    {{{ content }}}
        #  {{/ posts }}
        #
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
          #data = self.context['id'] ? self.context : self.context['page']
          #return '' unless data['id']
          content = @ruhoh.db.content(pointer)
          [content, id]
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

          content = content.lines.to_a[0, line_breakpoint].join
          content = master.render(content)
          Ruhoh::Converter.convert(content, id)
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
  end
end