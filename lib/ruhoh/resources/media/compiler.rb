module Ruhoh::Resources::Media
  class Compiler < Ruhoh::Resources::Base::Compiler
    def run
      return unless @ruhoh.resources.exists?('media')
      collection = @ruhoh.resources.load_collection('media')
      media_path = File.join(@ruhoh.paths.base, collection.path)
      return unless FileTest.directory? media_path
      
      media = Ruhoh::Utils.url_to_path(collection.url_endpoint, @ruhoh.paths.compiled)
      FileUtils.mkdir_p media
      FileUtils.cp_r(File.join(media_path, '.'), media)
    end
  end
end
