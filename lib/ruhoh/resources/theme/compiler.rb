module Ruhoh::Resources::Theme
  class Compiler < Ruhoh::Resources::Base::Compiler

    def run
      copy
    end

    # Copies all assets over to the compiled site.
    # Note the compiled assets are namespaced at /assets/<theme-name>/
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
        Ruhoh::Friend.say { green "  > #{file}" }
      end
    end

    # Returns list of all files from the theme to be compiled.
    # @returns[Array] relative filepaths
    def files
      FileUtils.cd(@ruhoh.paths.theme) {
        return Dir["**/*"].select { |filepath|
          is_valid_asset?(filepath)
        }
      }
    end

    # Checks a given asset filepath against any user-defined exclusion rules in theme.yml
    # Omit layouts, stylesheets, javascripts as they are handled by their respective resources.
    # @returns[Boolean]
    def is_valid_asset?(filepath)
      return false if FileTest.directory?(filepath)
      return false if filepath.start_with?('layouts', 'stylesheets', 'javascripts') 
      @ruhoh.db.config("theme")["exclude"].each {|regex| return false if filepath =~ regex }
      true
    end
  end
end