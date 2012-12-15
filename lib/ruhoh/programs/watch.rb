require 'directory_watcher'

class Ruhoh
  module Program

    # Internal: Watch website source directory for file changes.
    # The observer triggers data regeneration as files change
    # in order to keep the data up to date in real time.
    #
    # Returns: Nothing
    def self.watch(ruhoh)
      ruhoh.ensure_setup

      Ruhoh::Friend.say {
        cyan "=> Start watching: #{ruhoh.paths.base}"
      }
      
      glob = ''
    
      # Watch all files + all sub directories except for special folders e.g '_database'
      Dir.chdir(ruhoh.paths.base) {
        dirs = Dir['*'].select { |x| File.directory?(x) }
        dirs = dirs.map { |x| "#{x}/**/*" }
        dirs += ['*']
        glob = dirs
      }
      dw = DirectoryWatcher.new(ruhoh.paths.base, {
        :glob => glob, 
        :pre_load => true
      })
      dw.interval = 1
      dw.add_observer {|*args| 
        args.each {|event|
          path = event['path'].gsub(ruhoh.paths.base + '/', '')

          watchers = ruhoh.resources.all.keys.map {|name|
            next unless ruhoh.resources.watcher?(name)
            ruhoh.resources.load_watcher(name)
          }.compact
          
          watchers.each {|watcher|
            next unless watcher.match(path)
            watcher.update(path)
            Ruhoh::Friend.say {
              yellow "Watch [#{Time.now.strftime("%H:%M:%S")}] [Update #{path}] : #{args.size} files changed"
            }
            return
          }
        }
      }

      dw.start
    end   

  end  #Watch
end #Ruhoh