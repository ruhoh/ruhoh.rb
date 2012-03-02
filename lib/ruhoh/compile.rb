class Ruhoh
  
  module Compile

    def self.generate
      File.open(Ruhoh.paths.posts_data, 'w') { |page|
        page.puts Ruhoh::Posts.generate.to_yaml
      }
  
      File.open(Ruhoh.paths.pages_data, 'w') { |page|
        page.puts Ruhoh::Pages.generate.to_yaml
      }
    end
  
  end #Compile
  
end #Ruhoh