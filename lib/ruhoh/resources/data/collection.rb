module Ruhoh::Resources::Data
  class Collection
    include Ruhoh::Base::Collectable

    def dictionary
      Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.base, "#{resource_name}.yml") || {}
    end
  end
end