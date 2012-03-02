class Ruhoh
  
  class Database
    class << self
      attr_accessor :config, :routes, :posts, :pages, :layouts, :partials
    end
    
    def self.get(name)
      self.__send__ name.to_s
    end

    def self.update
      self.update_config
      self.update_routes
      self.update_posts
      self.update_pages
      self.update_layouts
      self.update_partials
    end
    
    def self.update_config
      @config = YAML.load_file( File.join(Ruhoh.config.site_source_path, '_config.yml') )
    end
    
    def self.update_routes
      @routes = Ruhoh::Routes.generate
    end
    
    def self.update_posts
      @posts = Ruhoh::Posts.generate
    end
    
    def self.update_pages
      @pages = Ruhoh::Pages.generate
    end

    def self.update_layouts
      @layouts = Ruhoh::Layouts.generate
    end
    
    def self.update_partials
      @partials = Ruhoh::Partials.generate
    end
    
  end #Database
  
end #Ruhoh