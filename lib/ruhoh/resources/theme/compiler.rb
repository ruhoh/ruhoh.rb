module Ruhoh::Resources::Theme
  class Compiler
    include Ruhoh::Base::Compilable

    # Copies all assets over to the compiled site.
    # Note the compiled assets are namespaced at /assets/
    def run
      return unless setup_compilable

      self.files.each do |file|
        original_file = File.join(@ruhoh.cascade.theme, file)
        compiled_file = File.join(@collection.compiled_path, file)
        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r original_file, compiled_file
        Ruhoh::Friend.say { green "  > #{file}" }
      end
    end

    # Returns list of all files from the theme to be compiled.
    # @returns[Array] relative filepaths
    def files
      FileUtils.cd(@ruhoh.cascade.theme) {
        return Dir["**/*"].select { |filepath|
          is_valid_asset?(filepath)
        }
      }
    end

    # Checks a given asset filepath against any user-defined exclusion rules in config
    # Omit layouts, stylesheets, javascripts, media as they are handled by their respective resources.
    # @returns[Boolean]
    def is_valid_asset?(filepath)
      return false unless File.exist? filepath
      return false if FileTest.directory?(filepath)
      return false if filepath.start_with?('.', 'layouts', 'stylesheets', 'javascripts', 'media')
      excludes = Array(@collection.config['exclude']).map { |node| Regexp.new(node) }
      excludes.each { |regex| return false if filepath =~ regex }
      true
    end
  end
end