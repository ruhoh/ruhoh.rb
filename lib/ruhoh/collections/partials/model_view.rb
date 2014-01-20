module Ruhoh::Collections::Partials
  class ModelView  < SimpleDelegator
    def initialize(item, ruhoh)
      super(item)
      @ruhoh = ruhoh
    end

    def content
      @content ||= CGI.unescapeHTML(Ruhoh::Converter.convert(__getobj__.content, id))
    end
  end
end
