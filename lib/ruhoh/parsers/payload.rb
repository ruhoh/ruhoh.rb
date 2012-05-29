class Ruhoh
  module Parsers
    module Payload
      
      def self.generate
        {
          "db" => {
            "pages" =>  Ruhoh::DB.pages,
            "posts" => Ruhoh::DB.posts,
          },
          "site" => Ruhoh::DB.site,
          'page' => {},
          "paths" => {
            "stylesheets" => Ruhoh.urls.theme_stylesheets,
            "scripts" => Ruhoh.urls.theme_scripts,
            "theme_media" => Ruhoh.urls.theme_media,
            "media" => Ruhoh.urls.media,
          }
        }
      end
    end #Payload
  end #Parsers
end #Ruhoh