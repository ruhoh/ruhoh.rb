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
  #   use Rack::Static, {:urls => ["/#{Ruhoh.folders.media}", "/#{Ruhoh.folders.templates}"]}
  #   run Ruhoh::Previewer.new
  #
  class Previewer
    
    def initialize
      Ruhoh.config.env ||= 'development'
      Ruhoh::DB.update_all
      @page = Ruhoh::Page.new
      Ruhoh::Watch.start
    end

    def call(env)
      return favicon if env['PATH_INFO'] == '/favicon.ico'
      dash = File.basename(Ruhoh.files.dashboard, File.extname(Ruhoh.files.dashboard))
      return admin if ["/#{dash}", "/#{dash}/"].include?(env['PATH_INFO'])
      
      id = Ruhoh::DB.routes[env['PATH_INFO']]
      raise "Page id not found for url: #{env['PATH_INFO']}" unless id
      @page.change(id)

      [200, {'Content-Type' => 'text/html'}, [@page.render]]
    end
    
    def favicon
      [200, {'Content-Type' => 'image/x-icon'}, ['']]
    end

    def admin
      system_dash  = File.join(Ruhoh::Root, Ruhoh.files.dashboard)
      template     = File.open(File.exist?(Ruhoh.paths.dashboard) ? Ruhoh.paths.dashboard : system_dash) {|f| f.read }
      output       = Ruhoh::Templaters::Base.parse(template, nil)
      
      [200, {'Content-Type' => 'text/html'}, [output]]
    end
        
  end #Previewer
  
end #Ruhoh