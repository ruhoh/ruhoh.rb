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
      :theme_widgets
    )

    def self.generate
      urls                      = Urls.new
      urls.media                = self.to_url(Ruhoh.names.assets, Ruhoh.names.media)
      urls.widgets              = self.to_url(Ruhoh.names.assets, Ruhoh.names.widgets)
      urls.dashboard            = self.to_url(Ruhoh.names.dashboard_file.split('.')[0])

      urls.theme                = self.to_url(Ruhoh.names.assets, Ruhoh.config.theme)
      urls.theme_media          = self.to_url(Ruhoh.names.assets, Ruhoh.config.theme, Ruhoh.names.media)
      urls.theme_javascripts    = self.to_url(Ruhoh.names.assets, Ruhoh.config.theme, Ruhoh.names.javascripts)
      urls.theme_stylesheets    = self.to_url(Ruhoh.names.assets, Ruhoh.config.theme, Ruhoh.names.stylesheets)
      urls.theme_widgets        = self.to_url(Ruhoh.names.assets, Ruhoh.config.theme, Ruhoh.names.widgets)
      urls
    end

    # Ruhoh.config.base_path is assumed to be well-formed.
    # Always remove trailing slash.
    # Returns String - normalized url with prepended base_path
    def self.to_url(*args)
      url = args.join('/').chomp('/').reverse.chomp('/').reverse
      url = Ruhoh.config.base_path + url
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