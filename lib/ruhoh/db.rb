# Require all the resources
Dir[File.join(File.dirname(__FILE__), 'resources', '**', '*.rb')].each { |f|
  require f
}

class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB

    # Lazy-load all data endpoints but cache the result for this cycle.
    Ruhoh::Resources::Base::Collection.resources.keys.each do |name|
      class_eval <<-RUBY
        def #{name}
          return @#{name} if @#{name}
          update(:#{name})
          @#{name}
        end
      RUBY
    end
    
    def resources
      Ruhoh::Resources::Base::Collection.resources
    end

    def resource(name)
      resources[name]
    end
    
    def resource?(name)
      !!resources[name]
    end
    
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @content = {}
      @config = {}
      @urls = {}
      @paths = {}
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
      resource = collection(name).new(@ruhoh)

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
      resource = collection(name).new(@ruhoh)
      model = resource.model.new(resource, pointer)
      # TODO:
      # possible collisions here: ids are only unique relative to their resource dictionary.
      # that's the whole point of the pointer... =/
      @content[pointer['id']] = model.content
    end
    
    def urls
      @urls["base_path"] = @ruhoh.base_path
      return @urls if @urls.keys.length > 1 # consider base_url

      Ruhoh::Resources::Base::Collection.resources.each do |name, namespace|
        next unless namespace.const_defined?(:Collection)
        collection = namespace.const_get(:Collection).new(@ruhoh)
        next unless collection.respond_to?(:url_endpoint)
        @urls[name] = @ruhoh.to_url(collection.url_endpoint)
      end
      
      @urls
    end
    
    def paths
      return @paths unless @paths.empty?
      Ruhoh::Resources::Base::Collection.resources.each do |name, namespace|
        next unless namespace.const_defined?(:Collection)
        collection = namespace.const_get(:Collection).new(@ruhoh)
        next unless collection.respond_to?(:path)
        @paths[name] = collection.path
      end
      
      @paths
    end
    
    # Get the config for a given resource.
    def config(name)
      name = name.downcase
      return @config[name] if @config[name]
      @config[name] = collection(name).new(@ruhoh).config
    end
    
    def clear(name)
      self.instance_variable_set("@#{name}", nil)
    end
    
    %w{
      collection
      collection_view
      model
      model_view
      client
      compiler
      watcher
      previewer
    }.each do |method_name|
      constant_sym = method_name.to_s.split('_').map {|a| a.capitalize}.join.to_sym

      define_method(method_name) do |name|
        constantize(name).const_get(constant_sym)
      end

      define_method("#{method_name}?") do |name|
        constantize(name).const_defined?(constant_sym)
      end
    end
      
    def constantize(name)
      camelized_name = name.to_s.split('_').map {|a| a.capitalize}.join
      Ruhoh::Resources.const_get(camelized_name)
    end
    
  end #DB
end #Ruhoh