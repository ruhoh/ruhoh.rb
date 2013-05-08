module Ruhoh::Base

  module Compilable
    def self.included(klass)
      __send__(:attr_reader, :collection)
    end

    def initialize(collection)
      @ruhoh = collection.ruhoh
      @collection = collection
    end
  end

  module CompilableAsset
    include Compilable

    # A basic compiler task which copies each valid collection resource file to the compiled folder.
    # Valid files are identified by their pointers.
    # Invalid files are files that are excluded from the resource's configuration settings.
    # The collection's url_endpoint is used to determine the final compiled path.
    #
    # @returns Nothing.
    def run
      collection = @collection

      unless @collection.paths?
        Ruhoh::Friend.say { yellow "#{collection.resource_name.capitalize}: directory not found - skipping." }
        return
      end
      Ruhoh::Friend.say { cyan "#{collection.resource_name.capitalize}: (copying valid files)" }

      compiled_path = Ruhoh::Utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint), @ruhoh.paths.compiled)
      FileUtils.mkdir_p compiled_path
      
      manifest = {}
      @collection.files.values.each do |pointer|
        digest = Digest::MD5.file(pointer['realpath']).hexdigest
        digest_file = pointer['id'].sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
        manifest[pointer['id']] = digest_file

        compiled_file = File.join(compiled_path, digest_file)
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
