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
        use Rack::Static, {:urls => ["/#{Ruhoh.folders.media}", "/#{Ruhoh.folders.templates}"]}
        run Ruhoh::Previewer.new(Ruhoh::Page.new)
      }
    end
    
  end #Program
end #Ruhoh