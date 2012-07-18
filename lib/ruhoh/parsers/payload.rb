class Ruhoh
  module Parsers
    module Payload
      
      def self.generate
        payload = 
        {
          "db" => {
            "pages" =>  Ruhoh::DB.pages,
            "posts" => self.determine_category_and_tag_urls,
          },
          "site" => Ruhoh::DB.site,
          'page' => {},
          "urls" => {
            "theme_stylesheets" => Ruhoh.urls.theme_stylesheets,
            "theme_javascripts" => Ruhoh.urls.theme_javascripts,
            "theme_media" => Ruhoh.urls.theme_media,
            "media" => Ruhoh.urls.media,
          },
          "widgets" => {}
        }
        self.merge_widget_config(payload)
        payload
      end
      
      def self.merge_widget_config(payload)
        return if Ruhoh::DB.widgets == nil
        Ruhoh::DB.widgets.each do |widget_arr|
          name = widget_arr[0]
          config = widget_arr[1]['config']
          
          payload['widgets'][name] = { 'config' => config }
        end
      end
      
      # This is an ugly hack to determine the proper category and tag urls.
      # TODO: Refactor this out.
      def self.determine_category_and_tag_urls
        return nil unless Ruhoh::DB.routes && Ruhoh::DB.posts
        categories_url = nil
        ['/categories', '/categories.html'].each { |url|
          categories_url = url and break if Ruhoh::DB.routes.key?(url)
        }
        Ruhoh::DB.posts['categories'].each do |key, value|
          Ruhoh::DB.posts['categories'][key]['url'] = "#{categories_url}##{value['name']}-ref"
        end
        
        tags_url = nil
        ['/tags', '/tags.html'].each { |url|
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