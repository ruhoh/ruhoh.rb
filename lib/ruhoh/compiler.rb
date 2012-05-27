class Ruhoh
  module Compiler

    # TODO: seems rather dangerous to delete the incoming target directory?
    def self.compile(target_directory = nil, page = nil)
      Ruhoh.config.env ||= 'production'
      Ruhoh::Friend.say { plain "Compiling for environment: '#{Ruhoh.config.env}'" }
      target = target_directory || "./#{Ruhoh.names.compiled}"
      page = page || Ruhoh::Page.new
      
      FileUtils.rm_r target if File.exist?(target)
      FileUtils.mkdir_p target
      
      self.constants.each {|c|
        task = self.const_get(c)
        next unless task.respond_to?(:run)
        task.run(target, page)
      }  
      true
    end
    
    module Theme
      
      def self.run(target, page)
        self.stylesheets(target, page)
        self.scripts(target, page)
        self.media(target, page)
      end
      
      def self.stylesheets(target, page)
        Ruhoh::DB.stylesheets.each do |type, assets|
          assets.each do |asset|
            next unless File.exist?(asset['id'])
            file_path = self.url_to_path(File.dirname(asset['url']), target)
            FileUtils.mkdir_p file_path
            FileUtils.cp(asset['id'], file_path)
          end
        end
      end

      def self.scripts(target, page)
        Ruhoh::DB.scripts.each do |type, assets|
          assets.each do |asset|
            next unless File.exist?(asset['id'])
            file_path = self.url_to_path(File.dirname(asset['url']), target)
            FileUtils.mkdir_p file_path
            FileUtils.cp(asset['id'], file_path)
          end
        end
      end
      
      def self.media(target, page)
        return unless FileTest.directory? Ruhoh.paths.theme_media
        theme_media = self.url_to_path(Ruhoh.urls.theme_media, target)
        FileUtils.mkdir_p theme_media
        FileUtils.cp_r File.join(Ruhoh.paths.theme_media, '.'), theme_media
      end
      
      def self.url_to_path(url, target)
        File.__send__(:join, url.split('/').unshift(target))
      end
      
    end
    
    module Defaults

      def self.run(target, page)
        self.pages(target, page)
        self.media(target, page)
      end
      
      def self.pages(target, page)
        FileUtils.cd(target) {
          Ruhoh::DB.all_pages.each_value do |p|
            page.change(p['id'])

            FileUtils.mkdir_p File.dirname(page.compiled_path)
            File.open(page.compiled_path, 'w:UTF-8') { |p| p.puts page.render }

            Ruhoh::Friend.say { green "processed: #{p['id']}" }
          end
        }
      end

      def self.media(target, page)
        return unless FileTest.directory? Ruhoh.paths.media
        FileUtils.mkdir_p File.join(target, Ruhoh.names.media)
        FileUtils.cp_r Ruhoh.paths.media, target
      end
      
    end #Defaults

  end #Compiler
end #Ruhoh