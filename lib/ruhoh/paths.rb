class Ruhoh
  # Structured container for all paths to relevant directories and files in the system.
  # Paths are based on the ruhohspec for the Universal Blog API.
  # Additionally we store some system (gem) level paths for cascading to default functionality,
  # such as default widgets, default dashboard view, etc.
  module Paths
    Paths = Struct.new(
      :base,
      :compiled,
      :config_data,
      :dashboard_file,
      :media,
      :pages,
      :partials,
      :plugins,
      :posts,
      :scaffolds,
      :site_data,
      :themes,
      :widgets,
      
      :theme,
      
      :system,
      :system_dashboard_file,
      :system_scaffolds,
      :system_partials,
      :system_widgets
    )
    
    def self.generate(ruhoh)
      paths                     = Paths.new
      paths.base                = ruhoh.base
      paths.config_data         = File.join(ruhoh.base, Ruhoh.names.config_data)
      paths.media               = File.join(ruhoh.base, Ruhoh.names.media)
      paths.widgets             = File.join(ruhoh.base, Ruhoh.names.widgets)
      paths.compiled            = File.join(ruhoh.base, Ruhoh.names.compiled)
      paths.dashboard_file      = File.join(ruhoh.base, Ruhoh.names.dashboard_file)
      paths.site_data           = File.join(ruhoh.base, Ruhoh.names.site_data)
      paths.themes              = File.join(ruhoh.base, Ruhoh.names.themes)
      paths.plugins             = File.join(ruhoh.base, Ruhoh.names.plugins)
      
      paths.theme               = File.join(ruhoh.base, Ruhoh.names.themes, ruhoh.db.config('theme')['name'])
      
      return false unless self.theme_is_valid?(paths)
      
      paths.system                    = File.join(Ruhoh::Root, Ruhoh.names.system)
      paths.system_dashboard_file     = File.join(paths.system, Ruhoh.names.dashboard_file)
      paths.system_widgets            = File.join(paths.system, Ruhoh.names.widgets)

      paths
    end
    
    def self.theme_is_valid?(paths)
      return true if FileTest.directory?(paths.theme)
      Ruhoh.log.error("Theme directory does not exist: #{paths.theme}")
      return false
    end
    
  end #Paths
end #Ruhoh