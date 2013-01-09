module Ruhoh::Resources::Theme
  class Compiler < Ruhoh::Resources::Base::Compiler
      
      def run
        copy
      end

      # Copies all theme assets over to the compiled site.
      # Note the compiled assets are namespaced at /assets/<theme-name>/
      # theme.yml may specify exclusion rules for excluding assets.
      def copy
        theme_name = @ruhoh.db.config("theme")["name"]
        Ruhoh::Friend.say { cyan "Theme: (generating '#{theme_name}')" }

        url = @ruhoh.db.urls["theme"].gsub(/^\//, '')
        theme = Ruhoh::Utils.url_to_path(url, @ruhoh.paths.compiled)
        FileUtils.mkdir_p theme

        self.files.each do |file|
          original_file = File.join(@ruhoh.paths.theme, file)
          compiled_file = File.join(theme, file)
          FileUtils.mkdir_p File.dirname(compiled_file)
          FileUtils.cp_r original_file, compiled_file
          Ruhoh::Friend.say { green "  -> #{file}" }
        end
      end
      
      # Returns list of all files from the theme that need to be
      # compiled to the production environment.
      # Returns Array of relative filepaths
      def files
        FileUtils.cd(@ruhoh.paths.theme) {
          return Dir["**/*"].select { |filepath|
            next unless self.is_valid_asset?(filepath)
            true
          }
        }
      end

      # Checks a given asset filepath against any user-defined exclusion rules in theme.yml
      def is_valid_asset?(filepath)
        return false if FileTest.directory?(filepath)
        @ruhoh.db.config("theme")["exclude"].each {|regex| return false if filepath =~ regex }
        true
      end
    
  end
end
