module Ruhoh::Resources::Widgets
  class Compiler < Ruhoh::Resources::Base::Compiler
    def run
      collection = @collection
      unless @collection.paths?
        Ruhoh::Friend.say { yellow "#{collection.namespace.capitalize}: directory not found - skipping." }
        return
      end
      Ruhoh::Friend.say { cyan "#{collection.namespace.capitalize}: (copying valid files)" }

      compiled_path = Ruhoh::Utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint), @ruhoh.paths.compiled)
      FileUtils.mkdir_p compiled_path

      files = @collection.files
      # Don't copy over the layouts.
      files.delete_if { |p| p['id'].end_with?('.html') }
      files.each do |pointer|
        compiled_file = File.join(compiled_path, pointer['id'])
        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r pointer['realpath'], compiled_file
        Ruhoh::Friend.say { green "  > #{pointer['id']}" }
      end
    end
  end
end
