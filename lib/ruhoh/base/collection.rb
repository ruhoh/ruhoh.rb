module Ruhoh::Base

  module Collectable

    def self.included(klass)
      klass.__send__(:attr_accessor, :resource_name, :master)
      klass.__send__(:attr_reader, :ruhoh)
    end

    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    # Public API for finding a model instance inside this collection
    # @param[String or Hash]
    #  String - id (filename) with full extension, e.g: about-me.md
    #  String - name (filename) without the extension e.g: about-me
    #           Returns the first matched filename.
    #           See implementation for how match is determined.
    #  Hash   - File pointer
    #
    # @returns[model or nil] the model is always wrapped in its view.
    def find(name_or_pointer)
      name_or_pointer = name_or_pointer['id'] if name_or_pointer.is_a?(Hash)
      return dictionary[name_or_pointer] if dictionary.key?(name_or_pointer)
      key = dictionary.keys.find{ |a| a.split('.')[0] == name_or_pointer }
      key ? dictionary[key] : nil
    end

    # Public API
    # @returns[Hash object] collection's dictionary of data.
    def dictionary
      cached = @ruhoh.cache.get(resource_name)
      return cached if cached
      @ruhoh.cache.set(resource_name, process_all)
    end

    def resource_name
      return @resource_name if @resource_name
      parts = self.class.name.split("::")
      parts.pop
      Ruhoh::Utils.underscore(parts.pop)
    end

    # Implemented via Observable module
    # See http://ruby-doc.org/stdlib-1.9.3/libdoc/observer/rdoc/Observable.html
    # Collection subscribes to its child models.
    # #update is called on model #process.
    # noop
    def update(model_data)
    end

    def namespace
      Ruhoh::Utils.underscore(resource_name)
    end

    # The default glob for finding files.
    # Every file in all child directories.
    def glob
      "**/*"
    end

    # Default paths to the 3 levels of the cascade.
    def paths
      a = [
        {
          "name" => "system",
          "path" => @ruhoh.paths.system
        }, 
        {
          "name" => "base",
          "path" => @ruhoh.paths.base
        }
      ]
      a << {
        "name" => "theme",
        "path" => @ruhoh.paths.theme
      } if @ruhoh.paths.theme

      a
    end

    # Does this resource have any valid paths to process?
    # A valid path may exist on any of the cascade levels.
    # False means there are no directories on any cascade level.
    # @returns[Boolean]
    def paths?
      !!Array(paths.map{ |h| h["path"] }).find do |path|
        File.directory?(File.join(path, namespace))
      end
    end

    def config
      config = @ruhoh.config[resource_name] || {}
      unless config.is_a?(Hash)
        Ruhoh.log.error("'#{resource_name}' config key in config.yml is a #{config.class}; it needs to be a Hash (object).")
      end
      config
    end

    # Collect all files (as mapped by data resources) for this data endpoint.
    # Each resource can have 3 file references, one per each cascade level.
    # The file hashes are collected in order 
    # so they will overwrite eachother if found.
    # Returns Array of file data hashes.
    # 
    # id - (Optional) String or Array.
    #   Collect all files for a single data resource.
    #   Can be many files due to the cascade.
    # block - (Optional) block.
    #   Implement custom validation logic by passing in a block. The block is given (id, self) as args.
    #   Return true/false for whether the file is valid/invalid.
    #   Note it is preferred to pass the block to #process_all as #files is a low-level method.
    #
    # @returns[Array] pointers.
    def files(id=nil, &block)
      a = []
      Array(self.paths.map{|h| h["path"]}).each do |path|
        current_path = File.join(path, resource_name)
        next unless File.directory?(current_path)
        FileUtils.cd(current_path) {
          file_array = (id ? Array(id) : Dir[self.glob])
          file_array.each { |id|

            next unless(block_given? ? yield(id, self) : valid_file?(id))

            a << {
              "id" => id,
              "realpath" => File.realpath(id),
              "resource" => resource_name,
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
      excludes = Array(config['exclude']).map { |node| Regexp.new(node) }
      excludes.each { |regex| return false if filepath =~ regex }
      true
    end

    %w{
      collection_view
      model
      model_view
      client
      compiler
      watcher
      previewer
    }.each do |method_name|
      define_method(method_name) do
        get_module_namespace.const_get(camelize(method_name).to_sym)
      end

      define_method("#{method_name}?") do
        get_module_namespace.const_defined?(camelize(method_name).to_sym)
      end
    end

    def load_collection_view
      @_collection_view ||= collection_view? ?
                              collection_view.new(self) :
                              self
    end

    def load_model(pointer)
      _model = model? ?
                model.new(@ruhoh, pointer) :
                Ruhoh::Base::Model.new(@ruhoh, pointer)
      _model.add_observer(self)
      _model
    end

    def load_model_view(pointer)
      model_view? ? 
        model_view.new(load_model(pointer)) :
        Ruhoh::Base::ModelView.new(load_model(pointer))
    end

    def load_client(opts)
      @_client ||= client.new(load_collection_view, opts)
    end

    def load_compiler
      @_compiler ||= compiler.new(load_collection_view)
    end

    def load_watcher(*args)
      @_watcher ||= watcher? ?
        watcher.new(load_collection_view) :
        Ruhoh::Base::Watcher.new(load_collection_view)
    end

    def load_previewer(*args)
      @_previewer ||= previewer.new(@ruhoh)
    end

    protected

    # Load the registered resource else default to Pages if not configured.
    # @returns[Constant] the resource's module namespace
    def get_module_namespace
      type = @ruhoh.config[resource_name]["use"] rescue nil
      if type
        if @ruhoh.resources.registered.include?(type)
          Ruhoh::Resources.const_get(camelize(type))
        elsif @ruhoh.resources.base.include?(type)
          Ruhoh::Base.const_get(camelize(type))
        else
          klass = camelize(type)
          Friend.say {
            red "#{resource_name} resource set to use:'#{type}' in config.yml but Ruhoh::Resources::#{klass} does not exist."
          }
          abort
        end
      else
        if @ruhoh.resources.registered.include?(resource_name)
          Ruhoh::Resources.const_get(camelize(resource_name))
        else
          Ruhoh::Resources.const_get(:Pages)
        end
      end
    end

    def camelize(name)
      name.to_s.split('_').map { |a| a.capitalize }.join
    end

    private

    # Process all data resources for this data endpoint.
    #
    # id - (Optional) String or Array.
    #   Process a single data resource at id.
    # block - (Optional) block.
    #   Implement custom validation logic by passing in a block. The block is given (id, self) as args.
    #   Return true/false for whether the file is valid/invalid.
    #   Example:
    #     Process only files startng with the letter "a" :
    #     process_all {|id| id.start_with?("a") }
    #
    # @returns[Hash(dict)] dictionary of data hashes {"id" => {<data>}}
    def process_all(id=nil, &block)
      dict = {}
      files(id, &block).each { |pointer|
        dict.merge!({
          pointer['id'] => load_model_view(pointer)
        })
      }
      Ruhoh::Utils.report(resource_name, dict, [])
      dict
    end
  end

  # Generic base implementation of a Collection class.
  # All collections use this class by default
  # unless the Collection class is explicitly defined for the resource.
  class Collection
    include Collectable
  end

end