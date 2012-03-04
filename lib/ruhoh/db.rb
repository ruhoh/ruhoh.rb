require "observer"

class Ruhoh
  
  # Public: Database class for interacting with "data" in Ruhoh.
  #
  class DB
    
    class << self
      include Observable
      attr_reader :site, :routes, :posts, :pages, :layouts, :partials

      # Note this is class-level so you have to call it manually.
      def initialize
        @site       =  ''
        @routes       =  ''
        @posts        =  ''
        @pages        =  ''
        @layouts      =  ''
        @partials     =  ''
        self.update!
      end
      
      def update(name)
        self.instance_variable_set("@#{name}", 
          case name
          when :site
            site = File.join(Ruhoh.paths.site_source, '_site.yml')
            site = File.exist?(site) ? File.open(site).read : ''
            site = YAML.load(site) || {}
            
            config = File.join(Ruhoh.paths.site_source, '_config.yml')
            config = File.exist?(config) ? File.open(config).read : ''
            config = YAML.load(config) || {}
            
            site['config'] = config
            site
          when :routes
            Ruhoh::Routes.generate
          when :posts
            Ruhoh::Posts.generate
          when :pages
            Ruhoh::Pages.generate
          when :layouts
            Ruhoh::Layouts.generate
          when :partials
            Ruhoh::Partials.generate
          else
            raise "Data type: '#{name}' is not a valid data type."
          end
        )
        changed
        notify_observers(name)
      end

      def update!
        self.instance_variables.each { |var|
          self.__send__ :update, var.to_s.gsub('@', '').to_sym
        }
      end
      
    end #self
    
  end #DB
  
end #Ruhoh