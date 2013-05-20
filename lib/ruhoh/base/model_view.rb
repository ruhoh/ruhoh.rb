module Ruhoh::Base
  module ModelViewable
    def initialize(model)
      super(model)
      @model = model
      @ruhoh = model.ruhoh

      # Define direct access to the data Hash object
      # but don't overwrite methods if already defined.
      data.keys.each do |method|
        (class << self; self; end).class_eval do
          next if method_defined?(method)
          define_method method do |*args, &block|
            data[method]
          end
        end
      end
    end

    def <=>(other)
      id <=> other.id
    end

    def [](attribute)
      __send__(attribute)
    end

    def []=(key, value)
      __send__("#{key}=", value)
    end
  end

  module PageViewable
    include ModelViewable

    # Default order by alphabetical title name.
    def <=>(other)
      sort = @model.collection.config["sort"] || []
      attribute = sort[0] || "title"
      direction = sort[1] || "asc"

      this_data = __send__(attribute)
      other_data = other.__send__(attribute)
      if attribute == "date"
        begin
          this_data = Date.parse(this_data)
          other_data = Date.parse(other_data)
        rescue ArgumentError
          Ruhoh.log.error(
            "ArgumentError:" +
            " The '#{ @model.collection.resource_name }' collection is configured to sort based on 'date'" +
            " but '#{ @model.pointer['id'] }' has no parseable date in its metadata." +
            " Add date: 'YYYY-MM-DD' to its YAML metadata."
          )
        end
        direction = sort[1] || "desc" #default should be reverse
      end

      if direction == "asc"
        this_data <=> other_data
      else
        other_data <=> this_data
      end
    end

    def categories
      @model.collection.to_categories(data['categories'])
    end

    def tags
      @model.collection.to_tags(data['tags'])
    end

    # Lazy-load the page body.
    # Notes:
    # @content is not used for caching, it's used to manually
    # define content for a given page. Useful in the case that
    # you want to model a resource that does not actually
    # reference a file.
    def content
      return @content if @content
      content = @model.collection.master.render(@model.content)
      Ruhoh::Converter.convert(content, id)
    end

    def is_active_page
      id == @model.collection.master.page_data['id']
    end
    
    # Truncate the page content relative to a line_count limit.
    # This is optimized for markdown files in which content is largely
    # blocked into chunks and separating by blank lines.
    # The line_limit truncates content based on # of content-based lines,
    # so blank lines don't count toward the limit.
    # Always break the content on a blank line only so result stays formatted nicely.
    def summary
      line_limit = @model.collection.config['summary_lines']
      line_count = 0
      line_breakpoint = @model.content.lines.count

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

      summary = @model.collection.master.render(summary)
      Ruhoh::Converter.convert(summary, id)
    end

    def next
      return unless id
      all_cache = @model.collection.all
      index = all_cache.index {|p| p["id"] == id}
      return unless index && (index-1 >= 0)
      _next = all_cache[index-1]
      return unless _next
      _next
    end

    def previous
      return unless id
      all_cache = @model.collection.all
      index = all_cache.index {|p| p["id"] == id}
      return unless index && (index+1 >= 0)
      prev = all_cache[index+1]
      return unless prev
      prev
    end
  end

  class ModelView < SimpleDelegator
    include ModelViewable
  end
end