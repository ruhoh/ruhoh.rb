module Ruhoh::Resources::Media
  class Compiler
    include Ruhoh::Base::Compilable

    #  TODO: Use the asset compiler.
    # We can't use it now because there is automatic digest support
    # but currently no way to dynamically update all media links in views with digest path.
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
