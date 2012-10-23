class Ruhoh
  module Compiler
    class StaticAssets
      
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
      
      def run
        return
        self.media
        self.javascripts
      end
      
      def media
        return unless FileTest.directory? @ruhoh.paths.media
        url = @ruhoh.db.urls["media"].gsub(/^\//, '')
        media = Ruhoh::Utils.url_to_path(url, @ruhoh.paths.compiled)
        FileUtils.mkdir_p media
        FileUtils.cp_r File.join(@ruhoh.paths.media, '.'), media
      end
      
      # Create all the javascripts.
      # Javascripts may be registered from either a theme or a widget.
      # Technically the theme compiler may create javascripts relative to the theme.
      # This ensures the widget javascripts are created as well.
      def javascripts
        @ruhoh.db.javascripts.each do |type, assets|
          assets.each do |asset|
            url = asset['url'].gsub(/^\//, '')
            next unless File.exist?(asset['id'])
            file_path = Ruhoh::Utils.url_to_path(File.dirname(url), @ruhoh.paths.compiled)
            FileUtils.mkdir_p file_path
            FileUtils.cp(asset['id'], file_path)
          end
        end
      end
      
    end
  end
end