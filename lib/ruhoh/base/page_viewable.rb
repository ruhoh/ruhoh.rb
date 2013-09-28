require 'ruhoh/summarizer'
require 'ruhoh/base/model_viewable'
module Ruhoh::Base::PageViewable
  include Ruhoh::Base::ModelViewable

  # Default order by alphabetical title name.
  def <=>(other)
    sort = @model.collection.config["sort"] || []
    attribute = sort[0] || "title"
    direction = sort[1] || "asc"

    this_data = __send__(attribute)
    other_data = other.__send__(attribute)
    if attribute == "date"
      if this_data.nil? || other_data.nil?
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

  def summary
    model_data = @model.data
    collection_config = @model.collection.config

    line_limit = model_data['summary_lines'] ||
                 collection_config['summary_lines']
    stop_at_header = model_data['summary_stop_at_header'] ||
                     collection_config['summary_stop_at_header']

    Ruhoh::Summarizer.new({
      content: @ruhoh.master_view(@model.pointer).render_content,
      line_limit: line_limit,
      stop_at_header: stop_at_header
    }).generate
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
