module Ruhoh::Plugins
  class Site < Base

    def generate
      Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.base, "site.yml") || {}
    end

  end
end