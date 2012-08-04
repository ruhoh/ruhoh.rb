class Ruhoh
  module Compiler
    module Theme
      
      def self.run(target, page)
        self.stylesheets(target, page)
        self.javascripts(target, page)
        self.media(target, page)
      end
      
      def self.stylesheets(target, page)
        Ruhoh::DB.stylesheets.each do |type, assets|
          assets.each do |asset|
            url = asset['url'].gsub(/^\//, '')
            next unless File.exist?(asset['id'])
            file_path = Ruhoh::Utils.url_to_path(File.dirname(url), target)
            FileUtils.mkdir_p file_path
            FileUtils.cp(asset['id'], file_path)
          end
        end
      end

      def self.javascripts(target, page)
        Ruhoh::DB.javascripts.each do |type, assets|
          assets.each do |asset|
            url = asset['url'].gsub(/^\//, '')
            next unless File.exist?(asset['id'])
            file_path = Ruhoh::Utils.url_to_path(File.dirname(url), target)
            FileUtils.mkdir_p file_path
            FileUtils.cp(asset['id'], file_path)
          end
        end
      end
      
      def self.media(target, page)
        return unless FileTest.directory? Ruhoh.paths.theme_media
        url = Ruhoh.urls.theme_media.gsub(/^\//, '')
        theme_media = Ruhoh::Utils.url_to_path(url, target)
        FileUtils.mkdir_p theme_media
        FileUtils.cp_r File.join(Ruhoh.paths.theme_media, '.'), theme_media
      end
    end #Theme
  end #Compiler
end #Ruhoh