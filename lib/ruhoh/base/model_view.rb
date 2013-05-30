require 'nokogiri'

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
          this_data = Time.parse(this_data.to_s)
          other_data = Time.parse(other_data.to_s)
        rescue ArgumentError, TypeError
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
    
    # Generate a truncated summary.
    # - If a summary element (`<tag class="summary">...</tag>`) is specified
    #   in the content, return it.
    # - If summary_lines > 0, truncate after the first complete element where
    #   the number of summary lines is greater than summary_lines.
    # - If summary_stop_at_header is true, stop before any headers.
    def summary
      # Parse the document
      content_doc = Nokogiri::HTML.fragment(content)

      # Return a summary element if specified
      summary_el = content_doc.at_css('.summary')
      return summary_el.to_html unless summary_el.nil?

      # Get the configuration parameters
      # Default to the parameters provided in the page itself
      line_limit = @model.data['summary_lines']
      line_limit = @model.collection.config['summary_lines'] if line_limit.nil?
      stop_at_header = @model.data['summary_stop_at_header']
      stop_at_header = @model.collection.config['summary_stop_at_header'] if stop_at_header.nil?

      # Create the summary element.
      summary_doc = Nokogiri::XML::Node.new("div", Nokogiri::HTML::Document.new)
      summary_doc["class"] = "summary"

      # All "heading" elements.
      headings = Nokogiri::HTML::ElementDescription::HEADING + ["header", "hgroup"]

      content_doc.children.each do |node|
        if stop_at_header && headings.include?(node.name)
          summary_doc["class"] += " ellipsis"
          break
        end

        if line_limit > 0 && summary_doc.content.lines.to_a.length > line_limit
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
