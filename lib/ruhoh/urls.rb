class Ruhoh
  # Structured container for all pre-defined URLs in the system.
  # These URLs are used primarily for static assets in development mode.
  # When compiling, all urls are of course mapped literally to the asset filepaths.
  module Urls
    Urls = Struct.new(
      :media,
      :widgets,
      :theme,
      :theme_media,
      :theme_javascripts,
      :theme_stylesheets,
      :theme_widgets
    )

    def self.generate(ruhoh)
      urls                      = Urls.new
      urls.media                = ruhoh.to_url(Ruhoh.names.assets, Ruhoh.names.media)
      urls.widgets              = ruhoh.to_url(Ruhoh.names.assets, Ruhoh.names.widgets)

      urls.theme                = ruhoh.to_url(Ruhoh.names.assets, ruhoh.db.config('theme')['name'])
      urls.theme_media          = ruhoh.to_url(Ruhoh.names.assets, ruhoh.db.config('theme')['name'], Ruhoh.names.media)
      urls.theme_javascripts    = ruhoh.to_url(Ruhoh.names.assets, ruhoh.db.config('theme')['name'], Ruhoh.names.javascripts)
      urls.theme_stylesheets    = ruhoh.to_url(Ruhoh.names.assets, ruhoh.db.config('theme')['name'], Ruhoh.names.stylesheets)
      urls.theme_widgets        = ruhoh.to_url(Ruhoh.names.assets, ruhoh.db.config('theme')['name'], Ruhoh.names.widgets)
      urls
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