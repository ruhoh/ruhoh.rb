class Ruhoh
  module Parsers
    class Routes < Base

      def generate
        routes = {}
        @ruhoh.db.pages.each_value { |page|
          routes[page['url']] = page['id'] 
        }

        @ruhoh.db.posts['dictionary'].each_value { |page|
          routes[page['url']] = page['id'] 
        }
        
        routes
      end

    end
  end
end