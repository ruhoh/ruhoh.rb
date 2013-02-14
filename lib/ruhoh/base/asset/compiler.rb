require 'digest'
module Ruhoh::Base::Asset
  class Compiler < Ruhoh::Base::Compiler
    # A basic compiler task which copies each valid collection resource file to the compiled folder.
    # Valid files are identified by their pointers.
    # Invalid files are files that are excluded from the resource's configuration settings.
    # The collection's url_endpoint is used to determine the final compiled path.
    #
    # @returns Nothing.
    def run
      collection = @collection

      unless @collection.paths?
        Ruhoh::Friend.say { yellow "#{collection.namespace.capitalize}: directory not found - skipping." }
        return
      end
      Ruhoh::Friend.say { cyan "#{collection.namespace.capitalize}: (copying valid files)" }

      compiled_path = Ruhoh::Utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint), @ruhoh.paths.compiled)
      FileUtils.mkdir_p compiled_path
      
      manifest = {}
      @collection.files.each do |pointer|
        digest = Digest::MD5.file(pointer['realpath']).hexdigest
        digest_file = pointer['id'].sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
        manifest[pointer['id']] = digest_file

        compiled_file = File.join(compiled_path, digest_file)
        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r pointer['realpath'], compiled_file
        Ruhoh::Friend.say { green "  > #{pointer['id']}" }
      end

      # Update the paths to the digest format:
      collection_view = @ruhoh.resources.load_collection_view(collection.namespace)
      collection_view._cache.merge!(manifest)
    end
  end
end