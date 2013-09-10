require 'directory_watcher'

class Ruhoh
  module Program

    # Internal: Watch website source directory for file changes.
    # The observer triggers data regeneration as files change
    # in order to keep the data up to date in real time.
    def self.watch(ruhoh)
      ruhoh.ensure_setup

      Ruhoh::Friend.say {
        cyan "=> Start watching: #{ruhoh.paths.base}"
      }
      dw = DirectoryWatcher.new(ruhoh.paths.base, {
        :glob => "**/*", 
        :pre_load => true
      })
      dw.interval = 1
      dw.add_observer do |*args| 
        args.each do |event|
          ruhoh.cache.delete(event['path'])

          path = event['path'].gsub(ruhoh.paths.base + '/', '')

          Ruhoh::Friend.say {
            yellow "Watch [#{Time.now.strftime("%H:%M:%S")}] [Update #{path}] : #{args.size} files changed"
          }

          if %w{ config.json config.yml config.yaml }.include?(path)
            ruhoh.config true
          else
            separator = File::ALT_SEPARATOR ?
                        %r{#{ File::SEPARATOR }|#{ File::ALT_SEPARATOR }} :
                        File::SEPARATOR
            resource = path.split(separator)[0]

            ruhoh.cache.delete(ruhoh.collection(resource).files_cache_key)
            ruhoh.cache.delete("#{ resource }-all")

            puts("HERE", resource)

            ruhoh.collection(resource).load_watcher.update(path)
            puts(ruhoh.collection(resource))
          end
        end
      end

      dw.start
    end

  end
end
