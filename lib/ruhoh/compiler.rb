class Ruhoh
  
  class Compiler
    
    def initialize(target_directory)
      Ruhoh::DB.update!
      @target = target_directory || "./#{Ruhoh.folders.compiled}"
      @page = Ruhoh::Page.new
    end
    
    def compile
      FileUtils.rm_r @target if File.exist?(@target)
      FileUtils.mkdir @target
      self.theme
      self.pages
      self.media
      self.syntax
    end
    
    def pages
      processed = []
      
      FileUtils.cd(@target) {
        Ruhoh::DB.posts['dictionary'].merge(Ruhoh::DB.pages).each_value do |p|
          @page.change(p['id'])

          FileUtils.mkdir_p File.dirname(@page.compiled_path)
          File.open(@page.compiled_path, 'w') { |p| p.puts @page.render }

          processed << p
          Ruhoh::Friend.say { green "processed: #{p['id']}" }
        end
      }

    end
    
    def theme
      FileUtils.mkdir_p File.join(@target, Ruhoh.config.theme_path)
      FileUtils.cp_r Ruhoh.paths.theme, File.join(@target, Ruhoh.folders.templates, Ruhoh.folders.themes)
    end
    
    def media
      FileUtils.mkdir_p File.join(@target, Ruhoh.folders.media)
      FileUtils.cp_r Ruhoh.paths.media, @target
    end
    
    def syntax
      syntax_path = File.join(@target, Ruhoh.folders.templates, Ruhoh.folders.syntax)
      FileUtils.mkdir_p syntax_path
      FileUtils.cp_r "#{Ruhoh.paths.syntax}/.", syntax_path
    end
    
  end #Compiler
  
end #Ruhoh