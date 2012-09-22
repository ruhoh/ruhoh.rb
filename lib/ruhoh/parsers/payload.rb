class Ruhoh
  module Parsers
    class Payload < Base

      def generate
        {
          "db" => {
            "pages" =>  @ruhoh.db.pages,
            "posts" => self.determine_category_and_tag_urls,
          },
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
      
      # This is an ugly hack to determine the proper category and tag urls.
      # TODO: Refactor this out.
      def determine_category_and_tag_urls
        return nil unless @ruhoh.db.routes && @ruhoh.db.posts
        categories_url = nil
        [@ruhoh.to_url("categories"), @ruhoh.to_url("categories.html")].each { |url|
          categories_url = url and break if @ruhoh.db.routes.key?(url)
        }
        @ruhoh.db.posts['categories'].each do |key, value|
          @ruhoh.db.posts['categories'][key]['url'] = "#{categories_url}##{value['name']}-ref"
        end
        
        tags_url = nil
        [@ruhoh.to_url("tags"), @ruhoh.to_url("tags.html")].each { |url|
          tags_url = url and break if @ruhoh.db.routes.key?(url)
        }
        @ruhoh.db.posts['tags'].each do |key, value|
          @ruhoh.db.posts['tags'][key]['url'] = "#{tags_url}##{value['name']}-ref"
        end
        
        @ruhoh.db.posts
      end
      
    end #Payload
  end #Parsers
end #Ruhoh