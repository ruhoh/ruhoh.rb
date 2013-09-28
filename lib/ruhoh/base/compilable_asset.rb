require 'ruhoh/base/compilable'
module Ruhoh::Base::CompilableAsset
  include Ruhoh::Base::Compilable

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
