module Ruhoh::Resources::Media
  class Compiler < Ruhoh::Resources::Base::Compiler
    def run
      media_path = File.join(@ruhoh.paths.base, @collection.path)
      unless FileTest.directory? media_path
        Ruhoh::Friend.say { yellow "Media: directory not found - skipping." }
        return
      end
      
      Ruhoh::Friend.say { cyan "Media: (copying entire folder)" }
      media = Ruhoh::Utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint), @ruhoh.paths.compiled)
      FileUtils.mkdir_p media
      FileUtils.cp_r(File.join(media_path, '.'), media)
      Ruhoh::Friend.say { green "  > done!" }
    end
  end
end
