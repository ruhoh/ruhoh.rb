class Ruhoh
  # Structured container for all paths to relevant directories and files in the system.
  # Paths are based on the ruhohspec for the Universal Blog API.
  # Additionally we store some system (gem) level paths for cascading to default functionality,
  # such as default widgets, default dashboard view, etc.
  module Paths
    Paths = Struct.new(
      :base,
      :compiled,
      :config,
      :dashboard,
      :media,
      :pages,
      :partials,
      :plugins,
      :posts,
      :site,
      :site_source,
      :themes,
      :widgets,
      
      :theme_base,
      :theme_config,
      :theme_layouts,
      :theme_media,
      :theme_partials,
      :theme_scripts,
      :theme_stylesheets,
      :theme_widgets,
    
      :system_dashboard,
      :system_widgets
    )
    
    def self.generate(config, site_source)
      paths                     = Paths.new
      paths.site_source         = site_source
      paths.config              = File.join(site_source, Ruhoh.names.base_config)
      paths.pages               = File.join(site_source, Ruhoh.names.pages)
      paths.posts               = File.join(site_source, Ruhoh.names.posts)
      paths.partials            = File.join(site_source, Ruhoh.names.partials)
      paths.media               = File.join(site_source, Ruhoh.names.media)
      paths.widgets             = File.join(site_source, Ruhoh.names.widgets)
      paths.compiled            = File.join(site_source, Ruhoh.names.compiled)
      paths.dashboard           = File.join(site_source, Ruhoh.names.dashboard_file)
      paths.site                = File.join(site_source, Ruhoh.names.site_data)
      paths.themes              = File.join(site_source, Ruhoh.names.themes)
      paths.plugins             = File.join(site_source, Ruhoh.names.plugins)
      
      paths.theme_base          = File.join(site_source, Ruhoh.names.themes, config.theme)
      paths.theme_config        = File.join(paths.theme_base, Ruhoh.names.theme_config)
      paths.theme_layouts       = File.join(paths.theme_base, Ruhoh.names.layouts)
      paths.theme_stylesheets   = File.join(paths.theme_base, Ruhoh.names.stylesheets)
      paths.theme_scripts       = File.join(paths.theme_base, Ruhoh.names.scripts)
      paths.theme_media         = File.join(paths.theme_base, Ruhoh.names.media)
      paths.theme_widgets       = File.join(paths.theme_base, Ruhoh.names.widgets)
      paths.theme_partials      = File.join(paths.theme_base, Ruhoh.names.partials)

      paths.system_dashboard    = File.join(Ruhoh::Root, Ruhoh.names.dashboard_file)
      paths.system_widgets      = File.join(Ruhoh::Root, Ruhoh.names.widgets)

      paths
    end
  end #Paths
end #Ruhoh