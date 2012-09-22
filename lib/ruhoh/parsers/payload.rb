class Ruhoh
  module Parsers
    class Payload < Base

      def generate
        {
          "site" => @ruhoh.db.site,
          'page' => {},
          "urls" => {
            "theme" => @ruhoh.urls.theme,
            "theme_stylesheets" => @ruhoh.urls.theme_stylesheets,
            "theme_javascripts" => @ruhoh.urls.theme_javascripts,
            "theme_media" => @ruhoh.urls.theme_media,
            "media" => @ruhoh.urls.media,
            "base_path" => @ruhoh.config.base_path,
          }
        }
      end

    end #Payload
  end #Parsers
end #Ruhoh