class Ruhoh
  module Parsers
    module Routes
      @ruhoh = nil
      def self.generate(ruhoh)
        @ruhoh = ruhoh
        routes = {}
        @ruhoh.db.pages.each_value { |page|
          routes[page['url']] = page['id'] 
        }

        @ruhoh.db.posts['dictionary'].each_value { |page|
          routes[page['url']] = page['id'] 
        }
        
        routes
      end
    
    end #Routes
  end #Parsers
end #Ruhoh