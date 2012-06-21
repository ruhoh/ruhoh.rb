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
      :theme_javascripts,
      :theme_stylesheets,
      :theme_widgets,
      :docroot  # For constructing abs url
    )

    def self.generate(config)
      urls                      = Urls.new
      urls.docroot              = config.env == 'production' ?
              self.to_url(config.production_url) :
              self.to_url(config.dev_url)   # not sure if it's ok
      urls.media                = self.to_url(urls.docroot, Ruhoh.names.assets, Ruhoh.names.media)
      urls.widgets              = self.to_url(urls.docroot, Ruhoh.names.assets, Ruhoh.names.widgets)
      urls.dashboard            = self.to_url(urls.docroot, Ruhoh.names.dashboard_file.split('.')[0])

      urls.theme                = self.to_url(urls.docroot, Ruhoh.names.assets, config.theme)
      urls.theme_media          = self.to_url(urls.docroot, Ruhoh.names.assets, config.theme, Ruhoh.names.media)
      urls.theme_javascripts    = self.to_url(urls.docroot, Ruhoh.names.assets, config.theme, Ruhoh.names.javascripts)
      urls.theme_stylesheets    = self.to_url(urls.docroot, Ruhoh.names.assets, config.theme, Ruhoh.names.stylesheets)
      urls.theme_widgets        = self.to_url(urls.docroot, Ruhoh.names.assets, config.theme, Ruhoh.names.widgets)
      urls
    end
    
    def self.to_url(*args)
      args.unshift(nil).join('/').sub(/^\/+/, '')
    end
    
    def self.to_url_slug(title)
      CGI::escape self.to_slug(title)
    end
    
    # My Post Title ===> my-post-title
    def self.to_slug(title)
      title = title.to_s.downcase.strip.gsub(/[^\p{Word}+]/u, '-')
      title.gsub(/^\-+/, '').gsub(/\-+$/, '').gsub(/\-+/, '-')
    end
    
  end #Urls
end #Ruhoh
