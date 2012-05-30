class Ruhoh
  module Program
    
    # Public: A program for running ruhoh as a rack application
    # which renders singular pages via their URL.
    # 
    # Examples
    #
    #  In config.ru:
    #
    #   require 'ruhoh'
    #   run Ruhoh::Program.preview
    #
    # Returns: A new Rack builder object which should work inside config.ru
    def self.preview(watch=true)
      Ruhoh.setup
      Ruhoh::DB.update_all
      Ruhoh::Watch.start if watch
      Rack::Builder.new {
        use Rack::Lint
        use Rack::ShowExceptions

        # Serve base media
        map Ruhoh.urls.media do
          run Rack::File.new(Ruhoh.paths.media)
        end
        
        # Serve theme assets
        map Ruhoh.urls.theme_stylesheets do
          run Rack::File.new(Ruhoh.paths.theme_stylesheets)
        end
        map Ruhoh.urls.theme_scripts do
          run Rack::File.new(Ruhoh.paths.theme_scripts)
        end
        map Ruhoh.urls.theme_widgets do
          run Rack::File.new(Ruhoh.paths.theme_widgets)
        end
        
        # Serve widget javascripts
        map Ruhoh.urls.widgets do
          run Rack::File.new(Ruhoh.paths.widgets)
        end

        map '/' do
          run Ruhoh::Previewer.new(Ruhoh::Page.new)
        end
      }
    end
    
  end #Program
end #Ruhoh