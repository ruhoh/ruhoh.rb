module Ruhoh::Collections::Javascripts
  class CollectionView < Ruhoh::Collections::Asset::CollectionView
    def generate_html(url)
      "<script src='#{ url }'></script>"
    end
  end
end
