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
      self.posts.merge(self.pages)
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
    
    def constantize(name)
      camelized_name = name.to_s.split('_').map {|a| a.capitalize}.join
      Ruhoh::Parsers.const_get(camelized_name)
    end
    
    # Update a data endpoint
    #
    # name - String or Symbol representing the data enpoint.
    # id - (Optional) String filename(id) to a singular resource
    # from the named data endpoint.
    #
    # If id is passed, will update the singular resource only.
    # Useful for updating only the resource that has changed.
    # Returns the data that was updated.
    def update(name, id = nil)
      model = constantize(name).new(@ruhoh)
      if id
        data = model.generate_by_id(id).values.first
        endpoint = self.instance_variable_get("@#{name}")
        endpoint[id] = data
        data
      else
        data = model.generate
        self.instance_variable_set("@#{name}", data)
        data
      end
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