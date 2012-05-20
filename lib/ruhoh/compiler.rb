class Ruhoh
  module Compiler

    # TODO: seems rather dangerous to delete the incoming target directory?
    def self.compile(target_directory = nil, page = nil)
      Ruhoh.config.env ||= 'production'
      Ruhoh::Friend.say { plain "Compiling for environment: '#{Ruhoh.config.env}'" }
      target = target_directory || "./#{Ruhoh.folders.compiled}"
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
    
    module Defaults

      def self.run(target, page)
        self.pages(target, page)
        self.theme(target, page)
        self.media(target, page)
        self.syntax(target, page)
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

      def self.theme(target, page)
        return unless FileTest.directory? Ruhoh.paths.theme
        url_parts = Ruhoh.config.asset_path.split('/')
        target_asset_path = File.__send__(:join, url_parts.unshift(target))
        FileUtils.mkdir_p target_asset_path
        FileUtils.cp_r File.join(Ruhoh.paths.assets, '.'), target_asset_path
      end

      def self.media(target, page)
        return unless FileTest.directory? Ruhoh.paths.media
        FileUtils.mkdir_p File.join(target, Ruhoh.folders.media)
        FileUtils.cp_r Ruhoh.paths.media, target
      end

      def self.syntax(target, page)
        return unless FileTest.directory? Ruhoh.paths.syntax
        syntax_path = File.join(target, Ruhoh.folders.syntax)
        FileUtils.mkdir_p syntax_path
        FileUtils.cp_r "#{Ruhoh.paths.syntax}/.", syntax_path
      end
      
    end #Defaults

  end #Compiler
end #Ruhoh