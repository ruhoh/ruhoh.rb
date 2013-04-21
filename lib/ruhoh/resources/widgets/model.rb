module Ruhoh::Resources::Widgets
  class Model < Ruhoh::Base::Pages::Model
    def process
      data = parse_page_file['data']
      data['pointer'] = @pointer
      data['id'] = @pointer['id']
      data
    end
  end
end