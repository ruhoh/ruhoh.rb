module Ruhoh::Resources::Layouts
  class Model
    include Ruhoh::Base::PageLike

    def process
      parsed_page = parse_page_file
      # This ensures the call to @sub_layout.layout does not error.
      parsed_page['data']['layout'] ||= nil

      changed
      notify_observers(parsed_page)

      parsed_page
    end
  end
end