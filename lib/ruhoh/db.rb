require 'ruhoh/resources_interface'

class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB
    attr_reader :routes

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
        id = name_or_pointer['id']
        if id
          name = name_or_pointer['resource'].downcase
          if(@ruhoh.env == "production" && instance_variable_defined?("@_#{name}"))
            instance_variable_get("@_#{name}")[id]
          else
            resource = @ruhoh.resources.load_collection(name)
            data = resource.generate(id).values.first
            endpoint = self.instance_variable_get("@_#{name}") || {}
            endpoint[id] = data
            data
          end
        end
      else
        name = name_or_pointer.downcase # name is a stringified constant.
        if(@ruhoh.env == "production" && instance_variable_defined?("@_#{name}"))
          instance_variable_get("@_#{name}")
        else
          data = @ruhoh.resources.load_collection(name).generate
          instance_variable_set("@_#{name}", data)
          data
        end
      end
    end

    # return a given resource's file content
    def content(pointer)
      name = pointer['resource'].downcase # name is a stringified constant.
      if(@ruhoh.env == "production" && @content["#{name}_#{pointer['id']}"])
        @content["#{name}_#{pointer['id']}"]
      else
        model = @ruhoh.resources.load_model(name, pointer)
        @content["#{name}_#{pointer['id']}"] = model.content
      end
    end

    # Get the config for a given resource.
    def config(name)
      name = name.downcase
      return @config[name] if @config[name]
      @config[name] = @ruhoh.resources.load_collection(name).config
    end
    
    def clear(name)
      self.instance_variable_set("@_#{name}", nil)
    end

    def method_missing(name, *args, &block)
      return data_for(name.to_s) if @ruhoh.resources.exist?(name.to_s)
      super
    end

    def respond_to?(method)
      return true if @ruhoh.resources.exist?(method.to_s)
      super
    end

    protected

    # Lazy-load all data endpoints but cache the result for this cycle.
    def data_for(resource)
      if instance_variable_defined?("@_#{resource}")
        instance_variable_get("@_#{resource}")
      else
        update(resource)
      end
    end
  end #DB
end #Ruhoh