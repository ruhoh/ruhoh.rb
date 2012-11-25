# Require all the resources
Dir[File.join(File.dirname(__FILE__), 'resources', '**', '*.rb')].each { |f|
  require f
}

class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB

    # Lazy-load all data endpoints but cache the result for this cycle.
    Ruhoh::Resources::Base::Parser.resources.keys.each do |name|
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
      @config = {}
      @urls = {}
      @paths = {}
    end
    
    def constantize(name)
      camelized_name = name.to_s.split('_').map {|a| a.capitalize}.join
      Ruhoh::Resources.const_get(camelized_name)
    end
    
    def parser(name)
      constantize(name).const_get(:Parser)
    end
    
    # Get a data endpoint from pointer
    # Note this differs from update in that
    # it should retrieve the cached version.
    def get(pointer)
      name = pointer['resource'].downcase
      id = pointer['id']
      raise "Invalid data type #{name}" unless self.respond_to?(name)
      data = self.__send__(name)[id]
      data ? data : self.update(pointer)
    end
    
    # Update a data endpoint
    #
    # name_or_pointer - String, Symbol or pointer(Hash)
    #
    # If pointer is passed, will update the singular resource only.
    # Useful for updating only the resource that have changed.
    #
    # Returns the data that was updated.
    def update(name_or_pointer)
      if name_or_pointer.is_a?(Hash)
        name = name_or_pointer['resource'].downcase
        id = name_or_pointer['id']
      else
        name = name_or_pointer.downcase # name is a stringified constant.
      end
      resource = parser(name).new(@ruhoh)

      if id
        data = resource.generate(id).values.first
        endpoint = self.instance_variable_get("@#{name}") || {}
        endpoint[id] = data
        data
      else
        data = resource.generate
        self.instance_variable_set("@#{name}", data)
        data
      end
    end

    # return a given resource's file content
    # TODO: Cache this in compile mode but not development mode.
    def content(pointer)
      name = pointer['resource'].downcase # name is a stringified constant.
      resource = parser(name).new(@ruhoh)
      modeler = resource.modeler.new(resource, pointer)
      # TODO:
      # possible collisions here: ids are only unique relative to their resource dictionary.
      # that's the whole point of the pointer... =/
      @content[pointer['id']] = modeler.content
    end
    
    def urls
      @urls["base_path"] = @ruhoh.config['base_path']
      return @urls if @urls.keys.length > 1 # consider base_url

      Ruhoh::Resources::Base::Parser.resources.each do |name, namespace|
        next unless namespace.const_defined?(:Parser)
        parser = namespace.const_get(:Parser).new(@ruhoh)
        next unless parser.respond_to?(:url_endpoint)
        @urls[name] = @ruhoh.to_url(parser.url_endpoint)
      end
      
      @urls
    end
    
    def paths
      return @paths unless @paths.empty?
      Ruhoh::Resources::Base::Parser.resources.each do |name, namespace|
        next unless namespace.const_defined?(:Parser)
        parser = namespace.const_get(:Parser).new(@ruhoh)
        next unless parser.respond_to?(:path)
        @paths[name] = parser.path
      end
      
      @paths
    end
    
    # Get the config for a given resource.
    def config(name)
      name = name.downcase
      return @config[name] if @config[name]
      @config[name] = parser(name).new(@ruhoh).config
    end
    
    def clear(name)
      self.instance_variable_set("@#{name}", nil)
    end
    
  end #DB
end #Ruhoh