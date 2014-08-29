module Ruhoh::Collections::Pages
  class ModelView  < SimpleDelegator
    attr_accessor :page_number

    def initialize(item, ruhoh)
      super(item)
      @ruhoh = ruhoh
      # Define direct access to the data Hash object
      # but don't overwrite methods if already defined.
      item.data.keys.each do |method|
        (class << self; self; end).class_eval do
          next if method_defined?(method)
          define_method method do |*args, &block|
            __getobj__.data[method]
          end
        end
      end
    end

    def resource
      @resource ||= id.index('/').nil? ? "_root" : id.split('/').first
    end

    def <=>(other)
      id <=> other.id
    end

    def [](attribute)
      respond_to?(attribute) ? __send__(attribute) : nil
    end

    def []=(key, value)
      __send__("#{key}=", value)
    end

    def url
      @url ||= @ruhoh.to_url(self['_url'] || id)
    end

    def title
      Silly::StringFormat.titleize(__getobj__.data["title"].to_s)
    end

    def categories
      __getobj__.collection.to_categories(__getobj__.data['categories'])
    end

    def tags
      __getobj__.collection.to_tags(__getobj__.data['tags'])
    end

    # Lazy-load the page body.
    # Notes:
    # @content is not used for caching, it's used to manually
    # define content for a given page. Useful in the case that
    # you want to model a resource that does not actually
    # reference a file.
    def content
      @content ||= Ruhoh::Converter.convert(__getobj__.content, id)
    end

    def is_active_page
      id == collection.master.page.id
    end

    def config
      @ruhoh.config.collection(resource)
    end

    def summary
      model_data = __getobj__.data
      line_limit = model_data['summary_lines'] ||
                   config['summary_lines']
      stop_at_header = model_data['summary_stop_at_header'] ||
                       config['summary_stop_at_header']

      Ruhoh::Summarizer.new({
        content: content,
        line_limit: line_limit,
        stop_at_header: stop_at_header
      }).generate
    end

    def next
      return unless id
      all_cache = collection.all.to_a
      index = all_cache.index{ |item| item.id == id }
      return unless index && (index-1 >= 0)
      _next = all_cache[index-1]
      return unless _next
      _next
    end

    def previous
      return unless id
      all_cache = collection.all.to_a
      index = all_cache.index{ |item| item.id == id }
      return unless index && (index+1 >= 0)
      prev = all_cache[index+1]
      return unless prev
      prev
    end
  end
end
