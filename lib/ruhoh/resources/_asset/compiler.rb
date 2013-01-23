module Ruhoh::Resources::Asset
  class Compiler < Ruhoh::Resources::Base::Compiler
    # A basic compiler task which copies each valid collection resource file to the compiled folder.
    # Valid files are identified by their pointers.
    # Invalid files are files that are excluded from the resource's configuration settings.
    # The collection's url_endpoint is used to determine the final compiled path.
    #
    # @returns Nothing.
    def run
      collection = @collection
      unless FileTest.directory? @collection.path
        Ruhoh::Friend.say { yellow "#{collection.namespace.capitalize}: directory not found - skipping." }
        return
      end
      Ruhoh::Friend.say { cyan "#{collection.namespace.capitalize}: (copying valid files)" }

      compiled_path = Ruhoh::Utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint), @ruhoh.paths.compiled)
      FileUtils.mkdir_p compiled_path
      
      @collection.files.each do |pointer|
        compiled_file = File.join(compiled_path, pointer['id'])
        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r pointer['realpath'], compiled_file
        Ruhoh::Friend.say { green "  > #{pointer['id']}" }
      end
    end
  end
end