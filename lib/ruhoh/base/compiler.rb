module Ruhoh::Base

  module Compilable
    def self.included(klass)
      __send__(:attr_reader, :collection)
    end

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
    end

    def setup_compilable
      return false unless collection_exists?

      compile_collection_path
    end

    def compile_collection_path
      FileUtils.mkdir_p(@collection.compiled_path)
    end

    def collection_exists?
      collection = @collection
      unless @collection.paths?
        Ruhoh::Friend.say { yellow "#{ collection.resource_name.capitalize }: directory not found - skipping." }
        return false
      end
      Ruhoh::Friend.say { cyan "#{ collection.resource_name.capitalize }: (copying valid files)" }
      true
    end
  end

  module CompilableAsset
    include Compilable

    # A basic compiler task which copies each valid collection resource file to the compiled folder.
    # This is different from the static compiler in that it supports fingerprinting.
    # Valid files are identified by their pointers.
    # Invalid files are files that are excluded from the resource's configuration settings.
    # The collection's url_endpoint is used to determine the final compiled path.
    #
    # @returns Nothing.
    def run
      return unless setup_compilable

      manifest = {}
      @collection.files.values.each do |pointer|
        digest = Digest::MD5.file(pointer['realpath']).hexdigest
        digest_file = pointer['id'].sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
        manifest[pointer['id']] = digest_file

        compiled_file = File.join(@collection.compiled_path, digest_file)
        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r pointer['realpath'], compiled_file
        Ruhoh::Friend.say { green "  > #{pointer['id']}" }
      end

      # Update the paths to the digest format:
      @collection.load_collection_view._cache.merge!(manifest)
    end
  end

  class Compiler
    include Ruhoh::Base::Compilable
  end
end
