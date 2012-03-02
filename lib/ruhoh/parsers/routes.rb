class Ruhoh
  
  module Routes

    #[{"url" => "id"}, ... ]
    def self.generate
      routes = {}
      Ruhoh::Pages.generate.each_value { |page|
        routes[page['url']] = page['id'] 
      }
      Ruhoh::Posts.generate['dictionary'].each_value { |page|
        routes[page['url']] = page['id'] 
      }
      
      routes
    end
    
  end #Routes
  
end #Ruhoh