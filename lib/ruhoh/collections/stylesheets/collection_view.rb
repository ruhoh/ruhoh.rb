module Ruhoh::Collections::Stylesheets
  class CollectionView < Ruhoh::Collections::Asset::CollectionView
    def generate_html(url)
      "<link href='#{ url }' type='text/css' rel='stylesheet' media='all'>"
    end
  end
end
