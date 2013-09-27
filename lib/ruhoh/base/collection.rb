module Ruhoh::Base

  module Collectable

    def self.included(klass)
      klass.__send__(:attr_accessor, :resource_name, :master)
      klass.__send__(:attr_reader, :ruhoh)
    end

    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    # Public API for finding a resource from this collection
    # @param name_or_pointer [String, Hash]
    #  Hash   - File pointer
    #  String - id (filename) with full extension, e.g: about-me.md
    #  String - name (filename) without the extension e.g: about-me
    #           Returns the first matched filename.
    #           See implementation for how match is determined.
    # @param opts [Hash] Optional options
    #  opts[:all] - true to search all files as some may be invalid as resources
    #
    # @return[model, nil] the model is always wrapped in its view.
    def find(name_or_pointer, opts={})
      pointer = find_file(name_or_pointer, opts)
      return nil unless pointer

      @ruhoh.cache.get(pointer['realpath']) ||
      @ruhoh.cache.set(pointer['realpath'], load_model_view(pointer))
    end

    # Public API
    # @return[Hash] dictionary of models { "id" => Model }
    def dictionary
      dict = {}
      files.values.each { |pointer|
        dict.merge!({
          pointer['id'] => find(pointer)
        })
      }
      dict
    end

    def resource_name
      @resource_name ||= self.class.name.split("::").pop
    end

    # Implemented via Observable module
    # See http://ruby-doc.org/stdlib-1.9.3/libdoc/observer/rdoc/Observable.html
    # Collection subscribes to its child models.
    # #update is called on model #process.
    # noop
    def update(model_data)
    end

    # The default glob for finding files.
    # Every file in all child directories.
    def glob
      "**/*"
    end

    # Default paths to the 3 levels of the cascade.
    def paths
      Array(@ruhoh.cascade.paths.map{|h| h["path"]}).map { |path|
        collection_path = File.join(path, resource_name)
        next unless File.directory?(collection_path)

        collection_path
      }.compact
    end

    # Does this resource have any valid paths to process?
    # A valid path may exist on any of the cascade levels.
    # False means there are no directories on any cascade level.
    # @returns[Boolean]
    def paths?
      !paths.empty?
    end

    def config
      config = @ruhoh.config[resource_name] || {}
      unless config.is_a?(Hash)
        Ruhoh.log.error("'#{resource_name}' config key in config" +
                        " is a #{config.class}; it needs to be a Hash (object).")
      end
      config
    end

    # NOOP
    # touch a model.
    # Used to perform custom regeneration logic against a model.
    def touch(name_or_pointer)
    end

    # @param key [String, Hash]
    #  String - id (filename) with full extension, e.g: about-me.md
    #  String - name (filename) without the extension e.g: about-me
    #           Returns the first matched filename.
    #           See implementation for how match is determined.
    #  Hash   - File pointer
    #
    # @param opts [Hash] Optional options
    #  opts[:all] - true to search all files as some may be invalid as resources
    #
    # @return [pointer, nil]
    def find_file(key, opts={})
      return key if key.is_a?(Hash) # assume valid pointer

      dict = opts[:all] ? _all_files : files

      dict[key] || dict.values.find{ |a| key == a['id'].gsub(/.[^.]+$/, '') }
    end

    # Collect all files (as mapped by data resources) for this data endpoint.
    # Each resource can have 3 file references, one per each cascade level.
    # The file hashes are collected in order 
    # so they will overwrite eachother if found.

    # @param id [String, Array] Optional.
    #   Collect all files for a single data resource.
    #   Can be many files due to the cascade.
    # @param [block] Optional.
    #   Implement custom validation logic by passing in a block.
    #   The block is given (id, self) as args.
    #   Return true/false for whether the file is valid/invalid.
    #
    # @return[Hash] dictionary of pointers.
    def files(id=nil, &block)
      return @ruhoh.cache.get(files_cache_key) if @ruhoh.cache.get(files_cache_key)

      dict = _all_files
      dict.keep_if do |id, pointer|
        block_given? ? yield(id, self) : valid_file?(id)
      end

      @ruhoh.cache.set(files_cache_key, dict)
      dict
    end

    # Collect all files within this collection, valid or otherwise.
    # Each resource can have 3 file references, one per each cascade level.
    # The file hashes are collected in order and overwrite eachother if found.
    # This is a low-level method, see #files for the public interface.
    #
    # @return[Hash] dictionary of pointers.
    def _all_files
      dict = {}
      paths.each do |path|
        FileUtils.cd(path) { 
          Dir[glob].each { |id|
            next unless File.exist?(id) && FileTest.file?(id)
            dict[id] = {
              "id" => id,
              "realpath" => File.realpath(id),
              "resource" => resource_name,
            }
          }
        }
      end

      dict
    end

    def valid_file?(filepath)
      return false if filepath.start_with?('.')
      return false if filepath.start_with?('_')
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

    def files_cache_key
      "#{ resource_name }-files"
    end

    def scaffold
      pointer = find_file('_scaffold', all: true) || @ruhoh.cascade.find_file('_scaffold')
      return '' unless pointer

      File.open(pointer['realpath'], 'r:UTF-8') { |f| f.read }
    end

    def compiled_path
      @compiled_path ||= @ruhoh.compiled_path(@ruhoh.to_url(url_endpoint))
    end

    protected

    # Load the registered resource else default to Pages if not configured.
    # @returns[Constant] the resource's module namespace
    def get_module_namespace
      type = @ruhoh.config[resource_name]["use"] rescue nil
      if type
        if @ruhoh.collections.registered.include?(type)
          Ruhoh::Resources.const_get(camelize(type))
        elsif @ruhoh.collections.base.include?(type)
          Ruhoh::Base.const_get(camelize(type))
        else
          klass = camelize(type)
          Friend.say {
            red "#{resource_name} resource set to use:'#{type}' in config" +
                " but Ruhoh::Resources::#{klass} does not exist."
          }
          abort
        end
      else
        if @ruhoh.collections.registered.include?(resource_name)
          Ruhoh::Resources.const_get(camelize(resource_name))
        else
          Ruhoh::Resources.const_get(:Pages)
        end
      end
    end

    def camelize(name)
      name.to_s.split('_').map { |a| a.capitalize }.join
    end
  end

  # Generic base implementation of a Collection class.
  # All collections use this class by default
  # unless the Collection class is explicitly defined for the resource.
  class Collection
    include Collectable
  end

end