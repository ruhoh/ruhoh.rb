class Ruhoh
  module Parsers
    # Sitewide data hash + configuration file.
    class Site < Base

      def generate
        site = Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.site_data) || {}
        config = Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.config_data)
        site['config'] = config
        site
      end

    end
  end
end