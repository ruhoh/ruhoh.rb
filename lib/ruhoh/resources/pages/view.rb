module Ruhoh::Resources::Pages
  class View < Ruhoh::Resources::Page::View
    
    def all
      pages = @ruhoh.db.pages.each_value.map { |val| val }
      pages = master.mark_active_page(pages)
      pages.map {|data|
        new_single(data)
      }
    end
    
  end
end
