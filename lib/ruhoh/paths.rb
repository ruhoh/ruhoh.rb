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
      :theme_config_data,
      :theme_dashboard_file,
      :theme_layouts,
      :theme_media,
      :theme_partials,
      :theme_javascripts,
      :theme_stylesheets,
      :theme_widgets,
      
      :system,
      :system_dashboard_file,
      :system_scaffolds,
      :system_partials,
      :system_widgets
    )
    
    def self.generate
      paths                     = Paths.new
      paths.base                = Ruhoh.base
      paths.config_data         = File.join(Ruhoh.base, Ruhoh.names.config_data)
      paths.pages               = File.join(Ruhoh.base, Ruhoh.names.pages)
      paths.posts               = File.join(Ruhoh.base, Ruhoh.names.posts)
      paths.partials            = File.join(Ruhoh.base, Ruhoh.names.partials)
      paths.media               = File.join(Ruhoh.base, Ruhoh.names.media)
      paths.widgets             = File.join(Ruhoh.base, Ruhoh.names.widgets)
      paths.compiled            = File.join(Ruhoh.base, Ruhoh.names.compiled)
      paths.dashboard_file      = File.join(Ruhoh.base, Ruhoh.names.dashboard_file)
      paths.site_data           = File.join(Ruhoh.base, Ruhoh.names.site_data)
      paths.themes              = File.join(Ruhoh.base, Ruhoh.names.themes)
      paths.plugins             = File.join(Ruhoh.base, Ruhoh.names.plugins)
      paths.scaffolds           = File.join(Ruhoh.base, Ruhoh.names.scaffolds)
      
      paths.theme               = File.join(Ruhoh.base, Ruhoh.names.themes, Ruhoh.config.theme)
      paths.theme_dashboard_file= File.join(paths.theme, Ruhoh.names.dashboard_file)
      paths.theme_config_data   = File.join(paths.theme, Ruhoh.names.theme_config)
      paths.theme_layouts       = File.join(paths.theme, Ruhoh.names.layouts)
      paths.theme_stylesheets   = File.join(paths.theme, Ruhoh.names.stylesheets)
      paths.theme_javascripts       = File.join(paths.theme, Ruhoh.names.javascripts)
      paths.theme_media         = File.join(paths.theme, Ruhoh.names.media)
      paths.theme_widgets       = File.join(paths.theme, Ruhoh.names.widgets)
      paths.theme_partials      = File.join(paths.theme, Ruhoh.names.partials)
      
      return false unless self.theme_is_valid?(paths)
      
      paths.system                    = File.join(Ruhoh::Root, Ruhoh.names.system)
      paths.system_dashboard_file     = File.join(paths.system, Ruhoh.names.dashboard_file)
      paths.system_partials           = File.join(paths.system, Ruhoh.names.partials)
      paths.system_scaffolds          = File.join(paths.system, Ruhoh.names.scaffolds)
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