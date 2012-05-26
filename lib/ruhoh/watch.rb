require 'directory_watcher'

class Ruhoh
  module Watch
  
    # Internal: Watch website source directory for file changes.
    # The observer triggers data regeneration as files change
    # in order to keep the data up to date in real time.
    #
    # Returns: Nothing
    def self.start
      Ruhoh.ensure_setup
      Ruhoh::Friend.say {
        plain "=> Start watching: #{Ruhoh.paths.base}"
      }
      glob = ''
    
      # Watch all files + all sub directories except for special folders e.g '_database'
      Dir.chdir(Ruhoh.paths.base) {
        dirs = Dir['*'].select { |x| File.directory?(x) }
        dirs = dirs.map { |x| "#{x}/**/*" }
        dirs += ['*']
        glob = dirs
      }

      dw = DirectoryWatcher.new(Ruhoh.paths.base, {
        :glob => glob, 
        :pre_load => true
      })
      dw.interval = 1
      dw.add_observer {|*args| 
        args.each {|event|
          path = event['path'].gsub(Ruhoh.paths.base, '')

          if path == "/#{Ruhoh.names.site_data}"
            type = "Site"
            Ruhoh::DB.update(:site)
          elsif path == "/#{Ruhoh.names.config_data}"
            type = "Config"
            Ruhoh::DB.update(:site)
          elsif path =~ Regexp.new("^\/?#{Ruhoh.names.pages}")
            type = "Pages"
            Ruhoh::DB.update(:pages)
            Ruhoh::DB.update(:routes)
          elsif path =~ Regexp.new("^\/?(#{Ruhoh.names.partials}|#{Ruhoh.names.themes}\/#{Ruhoh.config.theme}\/#{Ruhoh.names.partials})")
            type = "Partials"
            Ruhoh::DB.update(:partials)
          elsif path =~ Regexp.new("^\/?#{Ruhoh.names.posts}")
            type = "Posts"
            Ruhoh::DB.update(:posts)
            Ruhoh::DB.update(:routes)
          elsif path =~ Regexp.new("^\/?#{Ruhoh.names.themes}/#{Ruhoh.config.theme}/#{Ruhoh.names.layouts}")
            type = "Layouts"
            Ruhoh::DB.update(:layouts)
          elsif path =~ Regexp.new("^\/?#{Ruhoh.names.themes}/#{Ruhoh.config.theme}")
            type = "Themes"
            Ruhoh::DB.update(:assets)
            Ruhoh::DB.update(:widgets)
            Ruhoh::DB.update(:layouts)
          elsif path =~ Regexp.new("^\/?#{Ruhoh.names.widgets}")
            type = "Widgets"
            Ruhoh::DB.update(:widgets)
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