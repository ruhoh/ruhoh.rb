module Ruhoh::Resources::Widgets
  class Model
    include Ruhoh::Base::PageLike

    def process
      parsed = parse_page_file
      @data = parsed['data']
      @content = parsed['content']
      parsed
    end
  end
end