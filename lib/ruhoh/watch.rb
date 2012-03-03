require 'directory_watcher'

class Ruhoh
  module Watch
  
    # Internal: Watch website source directory for file changes.
    # The observer triggers data regeneration as files change
    # in order to keep the data up to date in real time.
    #
    # Returns: Nothing
    def self.start
      raise "Ruhoh.config cannot be nil.\n To set config call: Ruhoh.setup" unless Ruhoh.config
      puts "=> Start watching: #{Ruhoh.paths.site_source}"
      glob = ''
    
      # Watch all files + all sub directories except for special folders e.g '_database'
      Dir.chdir(Ruhoh.paths.site_source) {
        dirs = Dir['*'].select { |x| File.directory?(x) }
        dirs -= [Ruhoh.config.database_folder]
        dirs = dirs.map { |x| "#{x}/**/*" }
        dirs += ['*']
        glob = dirs
      }

      dw = DirectoryWatcher.new(Ruhoh.paths.site_source, {
        :glob => glob, 
        :pre_load => true
      })
      dw.interval = 1
      dw.add_observer {|*args| 
        args.each {|event|
          path = event['path'].gsub(Ruhoh.paths.site_source, '')
          puts path
          if path =~ /^\/?_posts/
            puts "Watch: update posts"
            Ruhoh::DB.update(:posts)
            Ruhoh::DB.update(:routes)
          elsif path =~ /^\/?_themes/
            puts "Watch: update themes"
            Ruhoh::DB.update(:layouts)
          else
            puts "Watch: update pages"
            Ruhoh::DB.update(:pages)
            Ruhoh::DB.update(:routes)
          end
  
          t = Time.now.strftime("%H:%M:%S")
          puts "[#{t}] regeneration: #{args.size} files changed"
        }
      }

      dw.start
    end   

  end  #Watch
end #Ruhoh