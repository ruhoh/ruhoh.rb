# Require all the plugins
Dir[File.join(File.dirname(__FILE__), 'plugins','*.rb')].each { |f|
  require f
}

class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB

    # Lazy-load all data endpoints but cache the result for this cycle.
    Ruhoh::Plugins::Base.plugins.keys.each do |name|
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
    end
    
    def constantize(name)
      camelized_name = name.to_s.split('_').map {|a| a.capitalize}.join
      Ruhoh::Plugins.const_get(camelized_name)
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
        endpoint = self.instance_variable_get("@#{name}") || {}
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
      modeler = constantize(name).modeler
      # TODO:
      # possible collisions here: ids are only unique relative to their parser.
      # that's the whole point of the pointer... =/
      @content[pointer['id']] = modeler.new(@ruhoh, pointer).content
    end
    
    def urls
      @urls["base_path"] = @ruhoh.config['base_path']
      return @urls if @urls.keys.length > 1 # consider base_url

      Ruhoh::Plugins::Base.plugins.each do |name, klass|
        plugin = klass.new(@ruhoh)
        next unless plugin.respond_to?(:url_endpoint)
        @urls[name] = @ruhoh.to_url(plugin.url_endpoint)
      end
      
      @urls
    end
    
    # Get the config for a given parser.
    def config(name)
      name = name.downcase
      return @config[name] if @config[name]
      @config[name] = constantize(name).new(@ruhoh).config
    end
    
    def clear(name)
      self.instance_variable_set("@#{name}", nil)
    end
    
  end #DB
end #Ruhoh