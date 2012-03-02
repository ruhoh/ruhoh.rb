require 'directory_watcher'

class Ruhoh
  module Watch
  
    # Internal: Watch website source directory for file changes.
    # The observer triggers data regeneration as files change
    # in order to keep the data up to date in real time.
    #
    #  site_source - Required [String] Path to the root directory 
    #    of the website source files.
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

          if path =~ /^\/?_posts/
            Ruhoh::Posts::generate
          else
            Ruhoh::Pages::generate
          end
  
          t = Time.now.strftime("%H:%M:%S")
          puts "[#{t}] regeneration: #{args.size} files changed"
        }
      }

      dw.start
    end   

  end  #Watch
end #Ruhoh