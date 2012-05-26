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
      :site_data,
      :themes,
      :widgets,
      
      :theme,
      :theme_config_data,
      :theme_dashboard_file,
      :theme_layouts,
      :theme_media,
      :theme_partials,
      :theme_scripts,
      :theme_stylesheets,
      :theme_widgets,
    
      :system_dashboard_file,
      :system_widgets
    )
    
    def self.generate(config, base)
      paths                     = Paths.new
      paths.base                = base
      paths.config_data         = File.join(base, Ruhoh.names.config_data)
      paths.pages               = File.join(base, Ruhoh.names.pages)
      paths.posts               = File.join(base, Ruhoh.names.posts)
      paths.partials            = File.join(base, Ruhoh.names.partials)
      paths.media               = File.join(base, Ruhoh.names.media)
      paths.widgets             = File.join(base, Ruhoh.names.widgets)
      paths.compiled            = File.join(base, Ruhoh.names.compiled)
      paths.dashboard_file      = File.join(base, Ruhoh.names.dashboard_file)
      paths.site_data           = File.join(base, Ruhoh.names.site_data)
      paths.themes              = File.join(base, Ruhoh.names.themes)
      paths.plugins             = File.join(base, Ruhoh.names.plugins)
      
      paths.theme               = File.join(base, Ruhoh.names.themes, config.theme)
      paths.theme_dashboard_file= File.join(paths.theme, Ruhoh.names.dashboard_file)
      paths.theme_config_data   = File.join(paths.theme, Ruhoh.names.theme_config)
      paths.theme_layouts       = File.join(paths.theme, Ruhoh.names.layouts)
      paths.theme_stylesheets   = File.join(paths.theme, Ruhoh.names.stylesheets)
      paths.theme_scripts       = File.join(paths.theme, Ruhoh.names.scripts)
      paths.theme_media         = File.join(paths.theme, Ruhoh.names.media)
      paths.theme_widgets       = File.join(paths.theme, Ruhoh.names.widgets)
      paths.theme_partials      = File.join(paths.theme, Ruhoh.names.partials)

      paths.system_dashboard_file = File.join(Ruhoh::Root, Ruhoh.names.dashboard_file)
      paths.system_widgets      = File.join(Ruhoh::Root, Ruhoh.names.widgets)

      paths
    end
  end #Paths
end #Ruhoh