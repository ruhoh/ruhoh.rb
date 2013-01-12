module Ruhoh::Resources::Base
  class Collection
    # Register all available resources.
    # @resources is a key value hash, e.g:
    #   "posts" => Ruhoh::Resources::Posts
    @resources = {}
    class << self
      attr_accessor :resources
      def inherited(resource)
        parts = resource.name.split("::")
        parts.pop
        name = parts.pop
        
        namespace = Ruhoh::Resources.const_get(name)
        name = Ruhoh::Utils.underscore(name)
        @resources[name] = namespace
      end
    end
    
    attr_reader :ruhoh
    
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end
    
    def registered_name
      self.class.registered_name
    end
    
    def namespace
      if self.class.class_variable_defined?(:@@namespace)
        self.class.class_variable_get(:@@namespace)
      else
        Ruhoh::Utils.underscore(registered_name)
      end
    end

    # The default glob for finding files.
    # Every file in all child directories.
    def glob
      "**/*"
    end
    
    # Default paths to the 3 levels of the cascade.
    def paths
      [
        {
          "name" => "system",
          "path" => @ruhoh.paths.system
        }, 
        {
          "name" => "base",
          "path" => @ruhoh.paths.base
        }, 
        {
          "name" => "theme",
          "path" => @ruhoh.paths.theme
        }
      ]
    end
    
    def config
      config = @ruhoh.config[registered_name] || {}
      unless config.is_a?(Hash)
        Ruhoh.log.error("'#{registered_name}' config key in config.yml is a #{config.class}; it needs to be a Hash (object).")
      end
      config
    end
    
    def path
      namespace
    end
    
    # Generate all data resources for this data endpoint.
    # Returns dictionary of all data resources.
    #
    # Generate a single data resource as identified by `id`
    # Returns dictionary containing the singular data resource.
    def generate(id=nil)
      dict = {}
      self.files(id).each { |pointer|
        pointer["resource"] = registered_name
        model = @ruhoh.resources.model(registered_name).new(@ruhoh, pointer)
        dict.merge!(model.generate)
      }
      Ruhoh::Utils.report(self.registered_name, dict, [])
      dict
    end

    # Collect all files (as mapped by data resources) for this data endpoint.
    # Each resource can have 3 file references, one per each cascade level.
    # The file hashes are collected in order 
    # so they will overwrite eachother if found.
    # Returns Array of file data hashes.
    # 
    # id - (Optional) String or Array.
    # Collect all files for a single data resource.
    # Can be many files due to the cascade.
    # Returns Array of file hashes.
    def files(id=nil)
      a = []
      Array(self.paths.map{|h| h["path"]}).each do |path|
        namespaced_path = File.join(path, namespace)
        next unless File.directory?(namespaced_path)
        FileUtils.cd(namespaced_path) {
          file_array = (id ? Array(id) : Dir[self.glob])
          file_array.each { |id|
            next unless self.valid_file?(id)
            a << {
              "id" => id,
              "realpath" => File.realpath(id),
              "resource" => registered_name,
            }
          }
        }
      end
      a
    end
    
    def valid_file?(filepath)
      return false unless File.exist? filepath
      return false if FileTest.directory?(filepath)
      return false if filepath.start_with?('.')
      Array(config['exclude']).each {|regex| return false if filepath =~ regex }
      true
    end
    
    def self.registered_name
      parts = name.split("::")
      parts.pop
      Ruhoh::Utils.underscore(parts.pop)
    end

    def self.registered_namespace
      Ruhoh::Resources::Base::Collection.resources[registered_name]
    end
  end
end