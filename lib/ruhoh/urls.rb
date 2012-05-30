class Ruhoh
  # Structured container for all pre-defined URLs in the system.
  # These URLs are used primarily for static assets in development mode.
  # When compiling, all urls are of course mapped literally to the asset filepaths.
  module Urls
    Urls = Struct.new(
      :media,
      :widgets,
      :dashboard,
      :theme,
      :theme_media,
      :theme_scripts,
      :theme_stylesheets,
      :theme_widgets
    )

    def self.generate(config)
      urls                      = Urls.new
      urls.media                = self.to_url(Ruhoh.names.assets, Ruhoh.names.media)
      urls.widgets              = self.to_url(Ruhoh.names.assets, Ruhoh.names.widgets)
      urls.dashboard            = self.to_url(Ruhoh.names.dashboard_file.split('.')[0])

      urls.theme                = self.to_url(Ruhoh.names.assets, config.theme)
      urls.theme_media          = self.to_url(Ruhoh.names.assets, config.theme, Ruhoh.names.media)
      urls.theme_scripts        = self.to_url(Ruhoh.names.assets, config.theme, Ruhoh.names.scripts)
      urls.theme_stylesheets    = self.to_url(Ruhoh.names.assets, config.theme, Ruhoh.names.stylesheets)
      urls.theme_widgets        = self.to_url(Ruhoh.names.assets, config.theme, Ruhoh.names.widgets)
      urls
    end
    
    def self.to_url(*args)
      args.unshift(nil).join('/')
    end
  end #Urls
end #Ruhoh