module Ruhoh::Resources::Posts
  class Collection < Ruhoh::Base::Pages::Collection
    def config
      hash = super
      hash['permalink'] ||= "/:categories/:year/:month/:day/:title"
      hash
    end
  end
end