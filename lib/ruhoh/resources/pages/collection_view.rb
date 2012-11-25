module Ruhoh::Resources::Pages
  class CollectionView < Ruhoh::Resources::Page::CollectionView
    
    def all
      pages = @ruhoh.db.pages.each_value.map { |val| val }
      pages = master.mark_active_page(pages)
      pages.map {|data|
        new_single(data)
      }
    end
    
  end
end
