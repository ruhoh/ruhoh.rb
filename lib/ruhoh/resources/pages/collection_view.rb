module Ruhoh::Resources::Pages
  class CollectionView < Ruhoh::Resources::Page::CollectionView
    def all
      @ruhoh.db.pages.each_value.map { |data|
        new_model_view(data)
      }.sort
    end
  end
end
