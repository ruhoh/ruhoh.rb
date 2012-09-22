# Require all the parsers
Dir[File.join(File.dirname(__FILE__), 'parsers','*.rb')].each { |f|
  require f
}

class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB
    WhiteList = [:site, :posts, :pages, :routes, :layouts, :partials, :widgets, :theme_config, :stylesheets, :javascripts, :payload, :scaffolds]

    self.__send__ :attr_reader, *WhiteList
    
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end
    
    def all_pages
      self.posts['dictionary'].merge(self.pages)
    end
    
    # Lazy-load all data endpoints but cache the result for this cycle.
    WhiteList.each do |name|
      class_eval <<-RUBY
        def #{name}
          return @#{name} if @#{name}
          update(:#{name})
          @#{name}
        end
      RUBY
    end
    
    def update(name)
      camelized_name = name.to_s.split('_').map {|a| a.capitalize}.join
      space = Ruhoh::Parsers.const_get(camelized_name).new(@ruhoh)
      self.instance_variable_set("@#{name}", space.generate)
    end
    
    def clear(name)
      self.instance_variable_set("@#{name}", nil)
    end
    
    def update_all
      WhiteList.each do |var|
        self.__send__(:update, var)
      end
    end
    
    # Refresh the database by clearing all cached values
    # This is used to start a fresh cycle.
    # It ensures updates to the data are reflected.
    def clear_all
      WhiteList.each do |var|
        self.instance_variable_set("@#{var}", nil)
      end
    end
    
  end #DB
end #Ruhoh