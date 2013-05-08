module Ruhoh::Resources::Media
  class Compiler
    include Ruhoh::Base::Compilable

    #  TODO: Use the asset compiler.
    # We can't use it now because there is automatic digest support
    # but currently no way to dynamically update all media links in views with digest path.
    def run
      collection = @collection
      unless @collection.paths?
        Ruhoh::Friend.say { yellow "#{collection.resource_name.capitalize}: directory not found - skipping." }
        return
      end
      Ruhoh::Friend.say { cyan "#{collection.resource_name.capitalize}: (copying valid files)" }

      compiled_path = Ruhoh::Utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint), @ruhoh.paths.compiled)
      FileUtils.mkdir_p compiled_path
      
      @collection.files.values.each do |pointer|
        compiled_file = File.join(compiled_path, pointer['id'])
        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r pointer['realpath'], compiled_file
        Ruhoh::Friend.say { green "  > #{pointer['id']}" }
      end
    end
  end
end
