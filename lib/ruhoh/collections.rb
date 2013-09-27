module Ruhoh::Resources ; end
# Require all the resources
FileUtils.cd(File.join(File.dirname(__FILE__), 'base')) do
  (Dir['*.rb'] + Dir[File.join('*', '*.rb')]).each do |f|
    require File.join(File.dirname(__FILE__), 'base', f)
  end
end
FileUtils.cd(File.join(File.dirname(__FILE__), 'resources')) do
  Dir[File.join('**', '*.rb')].each do |f|
    require File.join(File.dirname(__FILE__), 'resources', f)
  end
end

class Ruhoh
  class Collections
    def initialize(ruhoh)
      @ruhoh = ruhoh
      @collections = {}
    end

    def collection(resource)
      get_module_namespace_for(resource).const_get(:Collection)
    end

    def collection?(resource)
      get_module_namespace_for(resource).const_defined?(:Collection)
    end

    # Load and cache a given resource collection.
    # This allows you to work with single object instance and perform
    # persistant mutations on it if necessary.
    # Note the collection is always wrapped in its view.
    # @returns[Class Instance] of the resource and class_name given.
    def load(resource)
      return @collections[resource] if @collections[resource]
      instance =  collection?(resource) ?
                    collection(resource).new(@ruhoh) :
                    Ruhoh::Base::Collection.new(@ruhoh)
      instance.resource_name = resource
      @collections[resource] = instance.load_collection_view
    end

    # Load the CollectionView class for this resource.
    # Used primarily to as the plugin interface to include modules for mustache.
    def self.load(resource)
      get_module_namespace_for(resource).const_get(:CollectionView)
    end

    def all
      (discover + registered).to_a
    end

    def base
      Ruhoh::Base.constants.select{ |a|
        Ruhoh::Base.const_get(a).class == Module
      }.map{ |a| 
        a.to_s.downcase
      }
    end 

    def registered
      self.class.registered
    end

    def self.registered
      Ruhoh::Resources.constants.map{ |a| a.to_s.downcase }.delete_if{ |a| a == "pages" }
    end

    # discover all the resource mappings
    # @return[Set]
    def discover
      results = Set.new

      @ruhoh.cascade.paths.each do |h|
        FileUtils.cd(h["path"]) do
          results += Dir['*'].select { |x|
            File.directory?(x) && !["plugins", 'compiled'].include?(x)
          }
        end
      end

      results
    end

    def acting_as_pages
      pool = discover
      theme = @ruhoh.config['theme']['name'] rescue nil
      pool.delete(theme)

      pool.keep_if { |resource|
        config = @ruhoh.config[resource]
        if (config && config["use"]) 
          config["use"] == "pages"
        else
          if resource == "pages"
            true
          else
            !registered.include?(resource)
          end
        end
      }
    end

    def exists?(name)
      all.include?(name)
    end
    alias_method :exist?, :exists?

    def paginator_urls
      data = {}
      all.each do |name|
        paginator = load(name).config['paginator']['url'] rescue nil
        next if paginator.nil? || paginator.empty?

        data[name] = @ruhoh.to_url(paginator)
      end

      data
    end

    def url_endpoints
      urls = {}
      all.each do |name|
        collection = load(name)
        next unless collection.respond_to?(:url_endpoint)
        urls[name] = @ruhoh.to_url(collection.url_endpoint)
      end

      urls
    end

    def url_endpoints_sorted
      sorted_urls = url_endpoints.each.map {|k, v| {"name" => k, "url" => v} }
      sorted_urls.sort { |a, b| b["url"].length <=> a["url"].length }
    end

    protected

    # Load the registered resource else default to Pages if not configured.
    # @returns[Constant] the resource's module namespace
    def get_module_namespace_for(resource)
      type = @ruhoh.config[resource]["use"] rescue nil

      self.class.get_module_namespace_for(resource, type)
    end

    def self.get_module_namespace_for(resource, type=nil)
      if type
        if registered.include?(type)
          Ruhoh::Resources.const_get(camelize(type))
        elsif base.include?(type)
          Ruhoh::Base.const_get(camelize(type))
        else
          klass = camelize(type)
          Friend.say {
            red "#{resource} resource set to use:'#{type}' in config but Ruhoh::Resources::#{klass} does not exist."
          }
          abort
        end
      else
        if registered.include?(resource)
          Ruhoh::Resources.const_get(camelize(resource))
        else
          Ruhoh::Resources.const_get(:Pages)
        end
      end
    end

    def camelize(name)
      self.class.camelize(name)
    end

    def self.camelize(name)
      name.to_s.split('_').map {|a| a.capitalize}.join
    end
  end
end
