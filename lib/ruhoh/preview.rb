class Ruhoh
  
  # Public: Rack application used to render singular pages via their URL.
  # 
  # Examples
  #
  #  In config.ru:
  #
  #   require 'ruhoh'
  #
  #   Ruhoh.setup
  #   use Rack::Static, {:root => '.', :urls => ["/#{Ruhoh.config.site_source}"]}
  #   run Ruhoh::Preview.new
  #
  class Preview
    
    def initialize
      Ruhoh::DB.initialize
      @page = Ruhoh::Page.new
      Ruhoh::Watch.start(@page)
    end

    def call(env)
      return favicon if env['PATH_INFO'] == '/favicon.ico'
      
      @page.change(env['PATH_INFO'])
      [200, {'Content-Type' => 'text/html'}, [@page.render]]
    end
    
    def favicon
      [200, {'Content-Type' => 'image/x-icon'}, ['']]
    end

  end #Preview
  
end #Ruhoh