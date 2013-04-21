module Ruhoh::Resources::Widgets
  class Model < Ruhoh::Base::Pages::Model
    def process
      parsed = parse_page_file
      @data = parsed['data']
      @content = parsed['content']
      parsed
    end
  end
end