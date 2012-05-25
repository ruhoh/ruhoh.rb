class Ruhoh
  # Public: Rack application used to render singular pages via their URL.
  # 
  # This class depends on a correctly loaded Ruhoh environment;
  # it should only be used as part of a Ruhoh 'program' routine.
  # See Ruhoh::Program for usage.
  #
  class Previewer
    
    def initialize(page)
      Ruhoh.config.env ||= 'development'
      @page = page
    end

    def call(env)
      return favicon if env['PATH_INFO'] == '/favicon.ico'
      return admin if [Ruhoh.urls.dashboard, "#{Ruhoh.urls.dashboard}/"].include?(env['PATH_INFO'])
      
      id = Ruhoh::DB.routes[env['PATH_INFO']]
      raise "Page id not found for url: #{env['PATH_INFO']}" unless id
      @page.change(id)

      [200, {'Content-Type' => 'text/html'}, [@page.render]]
    end
    
    def favicon
      [200, {'Content-Type' => 'image/x-icon'}, ['']]
    end

    def admin
      template = File.open(File.exist?(Ruhoh.paths.dashboard) ? Ruhoh.paths.dashboard : Ruhoh.paths.system_dashboard, 'r:UTF-8') {|f| f.read }
      output = Ruhoh::Templaters::Base.parse(template, nil)
      
      [200, {'Content-Type' => 'text/html'}, [output]]
    end
        
  end #Previewer
end #Ruhoh