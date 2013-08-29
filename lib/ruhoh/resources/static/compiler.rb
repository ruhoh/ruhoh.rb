module Ruhoh::Resources::Static
  class Compiler
    include Ruhoh::Base::Compilable

    # A basic compiler task which copies each valid collection resource file to the compiled folder.
    # Valid files are identified by their pointers.
    # Invalid files are files that are excluded from the resource's configuration settings.
    # The collection's url_endpoint is used to determine the final compiled path.
    #
    # @returns Nothing.
    def run
      return unless setup_compilable

      @collection.files.values.each do |pointer|
        compiled_file = File.join(@collection.compiled_path, pointer['id'])

        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r pointer['realpath'], compiled_file

        Ruhoh::Friend.say { green "  > #{pointer['id']}" }
      end
    end
  end
end
