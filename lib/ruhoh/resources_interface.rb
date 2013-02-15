module Ruhoh::Resources ; end
# Require all the resources
FileUtils.cd(File.join(File.dirname(__FILE__), 'base')) do
  Dir['*.rb'].each do |f|
    require File.join(File.dirname(__FILE__), 'base', f)
  end
  Dir[File.join('*', '*.rb')].each do |f|
    require File.join(File.dirname(__FILE__), 'base', f)
  end
end
FileUtils.cd(File.join(File.dirname(__FILE__), 'resources')) do
  Dir[File.join('**', '*.rb')].each do |f|
    require File.join(File.dirname(__FILE__), 'resources', f)
  end
end

class Ruhoh
  class ResourcesInterface
    Whitelist = %w{
      collection
      collection_view
      model
      model_view
      client
      compiler
      watcher
      previewer
    }

    Whitelist.each do |method_name|
      define_method(method_name) do |name|
        get_module_namespace_for(name).const_get(camelize(method_name).to_sym)
      end

      define_method("#{method_name}?") do |name|
        get_module_namespace_for(name).const_defined?(camelize(method_name).to_sym)
      end
    end

    def method_missing(name, *args, &block)
      name = name.to_s
      resource = name.gsub(/^load_/, '')
      if Whitelist.include?(resource)
        load_class_instance_for(resource, *args)
      else
        super
      end
    end

    def respond_to?(method)
      resource = method.gsub(/^load_/, '')
      return true if Whitelist.include?(resource)
      super
    end


    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def all
      Ruhoh::Resources.constants.map{ |a| a.to_s.downcase }
    end

    def exists?(name)
      all.include?(name)
    end
    alias_method :exist?, :exists?

    protected

    # Load and cache a given resource class.
    # This allows you to work with single object instance and perform
    # persistant mutations on it if necessary.
    # TODO: Kind of ugly, maybe a better way to do this. Singleton?
    # @returns[Class Instance] of the resource and class_name given.
    def load_class_instance_for(class_name, resource)
      var = "@#{resource}_#{class_name}"
      if instance_variable_defined?(var) && instance_variable_get(var)
        instance_variable_get(var)
      else
        instance = get_module_namespace_for(resource).const_get(camelize(class_name).to_sym).new(@ruhoh)
        instance_variable_set(var, instance)
        instance_variable_get(var)
      end
    end

    def get_module_namespace_for(name)
      Ruhoh::Resources.const_get(camelize(name))
    end

    def camelize(name)
      self.class.camelize(name)
    end

    def self.camelize(name)
      name.to_s.split('_').map {|a| a.capitalize}.join
    end
  end
end