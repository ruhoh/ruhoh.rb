module Ruhoh::Resources::Posts
  class CollectionView < Ruhoh::Resources::Page::CollectionView

    def all
      @ruhoh.db.posts.each_value.map { |data|
        next if (File.basename(File.dirname(data['id'])) == "drafts")
        new_model_view(data)
      }.compact.sort
    end

    def drafts
      @ruhoh.db.posts.each_value.map { |data|
        next unless (File.basename(File.dirname(data['id'])) == "drafts")
        new_model_view(data)
      }.compact.sort
    end
  end
end