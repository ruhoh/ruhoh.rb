class Ruhoh

  module Parsers
    
    module Routes

      def self.generate
        routes = {}
        Ruhoh::Parsers::Pages.generate.each_value { |page|
          routes[page['url']] = page['id'] 
        }

        Ruhoh::Parsers::Posts.generate['dictionary'].each_value { |page|
          routes[page['url']] = page['id'] 
        }
        
        routes
      end
    
    end #Routes
  
  end #Parsers
  
end #Ruhoh