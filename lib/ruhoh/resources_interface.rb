# Require all the resources
Dir[File.join(File.dirname(__FILE__), 'resources', '**', '*.rb')].sort.each { |f|
  require f
}

class Ruhoh
  class ResourcesInterface
    
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end
    
    def all
      Ruhoh::Resources::Base::Collection.resources
    end

    def exists?(name)
      !!namespace(name)
    end
    alias_method :exist?, :exists?
    
    def namespace(name)
      all[name]
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
      
      define_method("load_#{method_name}") do |name|
        constantize(name).const_get(constant_sym).new(@ruhoh)
      end
    end
      
    def constantize(name)
      camelized_name = name.to_s.split('_').map {|a| a.capitalize}.join
      Ruhoh::Resources.const_get(camelized_name)
    end
    
  end
end