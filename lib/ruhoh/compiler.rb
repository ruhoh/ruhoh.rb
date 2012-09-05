require 'ruhoh/compilers/theme'
require 'ruhoh/compilers/rss'

class Ruhoh
  module Compiler

    # TODO: seems rather dangerous to delete the incoming target directory?
    def self.compile(target_directory = nil)
      Ruhoh::Friend.say { plain "Compiling for environment: '#{Ruhoh.config.env}'" }
      target = target_directory || "./#{Ruhoh.names.compiled}"
      
      FileUtils.rm_r target if File.exist?(target)
      FileUtils.mkdir_p target
      
      self.constants.each {|c|
        task = self.const_get(c)
        next unless task.respond_to?(:run)
        task.run({:target => target})
      }  
      true
    end
    
    module Defaults

      def self.run(opts)
        self.pages(opts)
        self.media(opts)
        self.javascripts(opts)
      end
      
      def self.pages(opts)
        FileUtils.cd(opts[:target]) {
          Ruhoh::DB.all_pages.each_value do |p|
            page = Ruhoh::Page.new(p['id'])

            FileUtils.mkdir_p File.dirname(page.compiled_path)
            File.open(page.compiled_path, 'w:UTF-8') { |p| p.puts page.render }

            Ruhoh::Friend.say { green "processed: #{p['id']}" }
          end
        }
      end
      
      def self.media(opts)
        return unless FileTest.directory? Ruhoh.paths.media
        url = Ruhoh.urls.media.gsub(/^\//, '')
        media = Ruhoh::Utils.url_to_path(url, opts[:target])
        FileUtils.mkdir_p media
        FileUtils.cp_r File.join(Ruhoh.paths.media, '.'), media
      end
      
      # Create all the javascripts.
      # Javascripts may be registered from either a theme or a widget.
      # Technically the theme compiler may create javascripts relative to the theme.
      # This ensures the widget javascripts are created as well.
      def self.javascripts(opts)
        Ruhoh::DB.javascripts.each do |type, assets|
          assets.each do |asset|
            url = asset['url'].gsub(/^\//, '')
            next unless File.exist?(asset['id'])
            file_path = Ruhoh::Utils.url_to_path(File.dirname(url), opts[:target])
            FileUtils.mkdir_p file_path
            FileUtils.cp(asset['id'], file_path)
          end
        end
      end
      
    end #Defaults

  end #Compiler
end #Ruhoh