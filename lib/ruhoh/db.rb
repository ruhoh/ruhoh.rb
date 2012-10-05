# Require all the parsers
Dir[File.join(File.dirname(__FILE__), 'parsers','*.rb')].each { |f|
  require f
}

class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB

    def self.registered_parsers
      return @registered_parsers if @registered_parsers
      @registered_parsers = Ruhoh::Parsers.constants.map{|c|
        Ruhoh::Utils.underscore(c)
      }
    end
    
    # Lazy-load all data endpoints but cache the result for this cycle.
    self.registered_parsers.each do |name|
      class_eval <<-RUBY
        def #{name}
          return @#{name} if @#{name}
          update(:#{name})
          @#{name}
        end
      RUBY
    end
    
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @content = {}
    end
    
    def constantize(name)
      camelized_name = name.to_s.split('_').map {|a| a.capitalize}.join
      Ruhoh::Parsers.const_get(camelized_name)
    end
    
    # Update a data endpoint
    #
    # name_or_pointer - String, Symbol or pointer(Hash)
    #
    # If pointer is passed, will update the singular resource only.
    # Useful for updating only the resource that have changed.
    # Returns the data that was updated.
    def update(name_or_pointer)
      if name_or_pointer.is_a?(Hash)
        name = name_or_pointer['type'].downcase
        id = name_or_pointer['id']
      else
        name = name_or_pointer.downcase # name is a stringified constant.
      end
      model = constantize(name).new(@ruhoh)

      if id
        data = model.generate(id).values.first
        endpoint = self.instance_variable_get("@#{name}")
        endpoint[id] = data
        data
      else
        data = model.generate
        self.instance_variable_set("@#{name}", data)
        data
      end
    end

    # return a given resource's file content
    # TODO: Cache this in compile mode but not development mode.
    def content(pointer)
      name = pointer['type'].downcase # name is a stringified constant.
      modeler = constantize(name).const_get(:Modeler)
      
      @content[pointer['id']] = modeler.new(@ruhoh, pointer).content
    end

    def clear(name)
      self.instance_variable_set("@#{name}", nil)
    end
    
  end #DB
end #Ruhoh