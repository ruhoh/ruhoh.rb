require 'ruhoh/compilers/theme'
require 'ruhoh/compilers/rss'

class Ruhoh
  module Compiler

    # TODO: seems rather dangerous to delete the incoming target directory?
    def self.compile(ruhoh)
      Ruhoh::Friend.say { plain "Compiling for environment: '#{ruhoh.config.env}'" }
      FileUtils.rm_r ruhoh.paths.compiled if File.exist?(ruhoh.paths.compiled)
      FileUtils.mkdir_p ruhoh.paths.compiled
      
      self.constants.each {|c|
        task = self.const_get(c)
        next unless task.respond_to?(:run)
        task.run(ruhoh)
      }  
      true
    end
    
    module Defaults

      def self.run(ruhoh)
        self.pages(ruhoh)
        self.media(ruhoh)
        self.javascripts(ruhoh)
      end
      
      def self.pages(ruhoh)
        FileUtils.cd(ruhoh.paths.compiled) {
          ruhoh.db.all_pages.each_value do |p|
            page = ruhoh.page(p['id'])

            FileUtils.mkdir_p File.dirname(page.compiled_path)
            File.open(page.compiled_path, 'w:UTF-8') { |p| p.puts page.render }

            Ruhoh::Friend.say { green "processed: #{p['id']}" }
          end
        }
      end
      
      def self.media(ruhoh)
        return unless FileTest.directory? ruhoh.paths.media
        url = ruhoh.urls.media.gsub(/^\//, '')
        media = Ruhoh::Utils.url_to_path(url, ruhoh.paths.compiled)
        FileUtils.mkdir_p media
        FileUtils.cp_r File.join(ruhoh.paths.media, '.'), media
      end
      
      # Create all the javascripts.
      # Javascripts may be registered from either a theme or a widget.
      # Technically the theme compiler may create javascripts relative to the theme.
      # This ensures the widget javascripts are created as well.
      def self.javascripts(ruhoh)
        ruhoh.db.javascripts.each do |type, assets|
          assets.each do |asset|
            url = asset['url'].gsub(/^\//, '')
            next unless File.exist?(asset['id'])
            file_path = Ruhoh::Utils.url_to_path(File.dirname(url), ruhoh.paths.compiled)
            FileUtils.mkdir_p file_path
            FileUtils.cp(asset['id'], file_path)
          end
        end
      end
      
    end #Defaults

  end #Compiler
end #Ruhoh