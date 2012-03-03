class Ruhoh
  
  class Compiler
    
    def initialize(target_directory)
      Ruhoh::DB.initialize
      @target = target_directory
      @page = Ruhoh::Page.new
      
      # Add a better way to do this.
      Ruhoh.config.asset_path = File.join('/', Ruhoh.folders.themes, Ruhoh.config.theme)
    end
    
    def compile
      FileUtils.mkdir @target unless File.exist?(@target)
      self.theme
      self.pages
    end
    
    def pages
      processed = []
      
      FileUtils.cd(@target) {
        Ruhoh::DB.posts['dictionary'].merge(Ruhoh::DB.pages).each_value do |page|
          path = CGI.unescape(page['url']).gsub(/^\//, '') #strip leading slash.
          path += '/index.html' unless path =~ /\.html$/

          @page.change(page['url'])
          FileUtils.mkdir_p File.dirname(path)
          File.open(path, 'w') { |p| p.puts @page.render }

          processed << path
        end
      }

      puts "=> Posts Processed:"
      puts processed
    end
    
    def theme
      FileUtils.mkdir_p File.join(@target, Ruhoh.config.asset_path)
      FileUtils.cp_r Ruhoh.paths.theme, File.join(@target, Ruhoh.folders.themes)
    end
    
    def write_data
      File.open(Ruhoh.paths.posts_data, 'w') { |page|
        page.puts Ruhoh::DB.posts.to_yaml
      }
  
      File.open(Ruhoh.paths.pages_data, 'w') { |page|
        page.puts Ruhoh::DB.pages.to_yaml
      }
    end
  
  end #Compiler
  
end #Ruhoh