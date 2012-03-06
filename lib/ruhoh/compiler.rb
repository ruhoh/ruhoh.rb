class Ruhoh
  
  class Compiler
    
    def initialize(target_directory = './_compiled')
      Ruhoh::DB.initialize
      @target = target_directory
      @page = Ruhoh::Page.new
    end
    
    def compile
      FileUtils.mkdir @target unless File.exist?(@target)
      self.theme
      self.pages
      self.media
    end
    
    def pages
      processed = []
      
      FileUtils.cd(@target) {
        Ruhoh::DB.posts['dictionary'].merge(Ruhoh::DB.pages).each_value do |p|
          @page.change(p['id'])
          
          FileUtils.mkdir_p File.dirname(@page.compiled_path)
          File.open(@page.compiled_path, 'w') { |p| p.puts @page.render }

          processed << path
        end
      }

      puts "=> Posts Processed:"
      puts processed
    end
    
    def theme
      FileUtils.mkdir_p File.join(@target, Ruhoh.config.asset_path)
      FileUtils.cp_r Ruhoh.paths.theme, File.join(@target, Ruhoh.folders.templates, Ruhoh.folders.themes)
    end
    
    def media
      FileUtils.mkdir_p File.join(@target, Ruhoh.folders.media)
      FileUtils.cp_r Ruhoh.paths.media, File.join(@target)
    end
    
    def write_data
      File.open(Ruhoh.paths.database + '/posts_dictionary.yml', 'w') { |page|
        page.puts Ruhoh::DB.posts.to_yaml
      }
  
      File.open(Ruhoh.paths.database + '/pages_dictionary.yml', 'w') { |page|
        page.puts Ruhoh::DB.pages.to_yaml
      }
    end
  
  end #Compiler
  
end #Ruhoh