require "observer"

class Ruhoh
  
  class Database
    
    class << self
      include Observable
      
      # Note this is class-level so you have to call it manually.
      def initialize
        @config       =  ''
        @routes       =  ''
        @posts        =  ''
        @pages        =  ''
        @layouts      =  ''
        @partials     =  ''
        self.update!
      end
      
      def get(name)
        self.instance_variable_get("@#{name}")
      end

      def update(name)
        self.instance_variable_set("@#{name}", 
          case name
          when :config
            YAML.load_file( File.join(Ruhoh.paths.site_source, '_config.yml') )
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
    
  end #Database
  
end #Ruhoh