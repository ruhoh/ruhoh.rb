module Ruhoh::Resources::Site
  class Parser < Ruhoh::Resources::Core::Base::Parser
    def generate
      Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.base, "site.yml") || {}
    end
  end
end