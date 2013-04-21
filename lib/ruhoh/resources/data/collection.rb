module Ruhoh::Resources::Data
  class Collection < Ruhoh::Base::Collection
    def process_all
      Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.base, "#{resource_name}.yml") || {}
    end
  end
end