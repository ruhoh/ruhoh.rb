require 'directory_watcher'

class Ruhoh
  module Watch
  
    # Internal: Watch website source directory for file changes.
    # The observer triggers data regeneration as files change
    # in order to keep the data up to date in real time.
    #
    # Returns: Nothing
    def self.start(ruhoh)
      ruhoh.ensure_setup

      Ruhoh::Friend.say {
        plain "=> Start watching: #{ruhoh.paths.base}"
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

          if path == Ruhoh.names.site_data
            type = "Site"
            ruhoh.db.clear(:site)
          elsif path == Ruhoh.names.config_data
            type = "Config"
            ruhoh.db.clear(:site)
          elsif path =~ Regexp.new("^#{Ruhoh.names.pages}")
            type = "Pages"
            ruhoh.db.clear(:pages)
            ruhoh.db.clear(:routes)
          elsif path =~ Regexp.new("^(#{Ruhoh.names.partials}|#{Ruhoh.names.themes}\/#{ruhoh.config.theme}\/#{Ruhoh.names.partials})")
            type = "Partials"
            ruhoh.db.clear(:partials)
          elsif path =~ Regexp.new("^#{Ruhoh.names.posts}")
            type = "Posts"
            ruhoh.db.clear(:posts)
            ruhoh.db.clear(:routes)
          elsif path =~ Regexp.new("^#{Ruhoh.names.themes}\/#{ruhoh.config.theme}\/#{Ruhoh.names.layouts}")
            type = "Layouts"
            ruhoh.db.clear(:layouts)
          elsif path =~ Regexp.new("^#{Ruhoh.names.themes}\/#{ruhoh.config.theme}")
            type = "Theme"
            ruhoh.db.clear(:stylesheets)
            ruhoh.db.clear(:javascripts)
            ruhoh.db.clear(:widgets)
            ruhoh.db.clear(:layouts)
          elsif path =~ Regexp.new("^#{Ruhoh.names.widgets}")
            type = "Widgets"
            ruhoh.db.clear(:widgets)
          else
            type = 'Unrecognized'
          end
          
          Ruhoh::Friend.say {
            yellow "Watch [#{Time.now.strftime("%H:%M:%S")}] [Update #{type}] : #{args.size} files changed"
          }
        }
      }

      dw.start
    end   

  end  #Watch
end #Ruhoh