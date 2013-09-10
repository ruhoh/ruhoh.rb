module Ruhoh::Resources::Data
  class Collection
    include Ruhoh::Base::Collectable

    def dictionary
      Ruhoh::Parse.data_file(@ruhoh.paths.base, resource_name) || {}
    end
  end
end