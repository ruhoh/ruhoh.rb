module Ruhoh::Resources::Posts
  class Collection < Ruhoh::Resources::Page::Collection
    def config
      hash = super
      hash['permalink'] ||= "/:categories/:year/:month/:day/:title"
      hash
    end
  end
end