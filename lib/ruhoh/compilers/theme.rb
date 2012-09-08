class Ruhoh
  module Compiler
    module Theme
      
      def self.run(ruhoh)
        self.copy(ruhoh)
      end

      # Copies all theme assets over to the compiled site.
      # Note the compiled assets are namespaced at /assets/<theme-name>/
      # theme.yml may specify exclusion rules for excluding assets.
      def self.copy(ruhoh)
        url = ruhoh.urls.theme.gsub(/^\//, '')
        theme = Ruhoh::Utils.url_to_path(url, ruhoh.paths.compiled)
        FileUtils.mkdir_p theme

        self.files(ruhoh).each do |file|
          original_file = File.join(ruhoh.paths.theme, file)
          compiled_file = File.join(theme, file)
          FileUtils.mkdir_p File.dirname(compiled_file)
          FileUtils.cp_r original_file, compiled_file
        end
      end
      
      # Returns list of all files from the theme that need to be
      # compiled to the production environment.
      # Returns Array of relative filepaths
      def self.files(ruhoh)
        FileUtils.cd(ruhoh.paths.theme) {
          return Dir["**/*"].select { |filepath|
            next unless self.is_valid_asset?(ruhoh, filepath)
            true
          }
        }
      end

      # Checks a given asset filepath against any user-defined exclusion rules in theme.yml
      def self.is_valid_asset?(ruhoh, filepath)
        return false if FileTest.directory?(filepath)
        ruhoh.db.theme_config["exclude"].each {|regex| return false if filepath =~ regex }
        true
      end
      
    end #Theme
  end #Compiler
end #Ruhoh