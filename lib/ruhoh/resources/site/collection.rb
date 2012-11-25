module Ruhoh::Resources::Site
  class Collection < Ruhoh::Resources::Base::Collection
    def generate
      Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.base, "site.yml") || {}
    end
  end
end