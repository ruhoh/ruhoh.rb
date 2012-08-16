class Ruhoh
  module Parsers
    module Payload
      
      def self.generate
        {
          "db" => {
            "pages" =>  Ruhoh::DB.pages,
            "posts" => self.determine_category_and_tag_urls,
          },
          "site" => Ruhoh::DB.site,
          'page' => {},
          "urls" => {
            "theme" => Ruhoh.urls.theme,
            "theme_stylesheets" => Ruhoh.urls.theme_stylesheets,
            "theme_javascripts" => Ruhoh.urls.theme_javascripts,
            "theme_media" => Ruhoh.urls.theme_media,
            "media" => Ruhoh.urls.media,
            "base_path" => Ruhoh.config.base_path,
          }
        }
      end
      
      # This is an ugly hack to determine the proper category and tag urls.
      # TODO: Refactor this out.
      def self.determine_category_and_tag_urls
        return nil unless Ruhoh::DB.routes && Ruhoh::DB.posts
        categories_url = nil
        ["#{Ruhoh.config.base_path}categories/", "#{Ruhoh.config.base_path}categories.html"].each { |url|
          categories_url = url and break if Ruhoh::DB.routes.key?(url)
        }
        Ruhoh::DB.posts['categories'].each do |key, value|
          Ruhoh::DB.posts['categories'][key]['url'] = "#{categories_url}##{value['name']}-ref"
        end
        
        tags_url = nil
        ["#{Ruhoh.config.base_path}tags/", "#{Ruhoh.config.base_path}tags.html"].each { |url|
          tags_url = url and break if Ruhoh::DB.routes.key?(url)
        }
        Ruhoh::DB.posts['tags'].each do |key, value|
          Ruhoh::DB.posts['tags'][key]['url'] = "#{tags_url}##{value['name']}-ref"
        end
        
        Ruhoh::DB.posts
      end
      
    end #Payload
  end #Parsers
end #Ruhoh