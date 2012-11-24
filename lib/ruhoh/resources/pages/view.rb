module Ruhoh::Resources::Pages
  class View < Ruhoh::Views::Helpers::Page::View
    
    def all
      pages = @ruhoh.db.pages.each_value.map { |val| val }
      pages = mark_active_page(pages)
      pages.map {|data|
        new_single(data)
      }
    end
    
  end
end
