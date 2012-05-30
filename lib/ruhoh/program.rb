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
    def self.preview(opts={})
      opts[:watch] ||= true
      opts[:env] ||= 'development'
      
      Ruhoh.setup
      Ruhoh.config.env = opts[:env]
      Ruhoh::DB.update_all
      Ruhoh::Watch.start if opts[:watch]
      Rack::Builder.new {
        use Rack::Lint
        use Rack::ShowExceptions

        # Serve base media
        map Ruhoh.urls.media do
          run Rack::File.new(Ruhoh.paths.media)
        end
        
        # Serve theme assets
        map Ruhoh.urls.theme do
          run Rack::File.new(Ruhoh.paths.theme)
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
    
    # Public: A program for compiling to a static website.
    # The compile environment should always be 'production' in order
    # to properly omit drafts and other development-only settings.
    def self.compile(target)
      Ruhoh.setup
      Ruhoh.config.env = 'production'
      Ruhoh::DB.update_all
      Ruhoh::Compiler.compile(target)
    end
    
  end #Program
end #Ruhoh