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
  #   use Rack::Static, {:root => '.', :urls => ['/_media', "/#{Ruhoh.folders.templates}"]}
  #   run Ruhoh::Preview.new
  #
  class Preview
    
    def initialize
      Ruhoh::DB.update!
      @page = Ruhoh::Page.new
      Ruhoh::Watch.start
    end

    def call(env)
      return favicon if env['PATH_INFO'] == '/favicon.ico'
      return drafts if env['PATH_INFO'] == '/_drafts'
      
      @page.change_with_url(env['PATH_INFO'])
      [200, {'Content-Type' => 'text/html'}, [@page.render]]
    end
    
    def favicon
      [200, {'Content-Type' => 'image/x-icon'}, ['']]
    end

    def drafts
      html = '<h3>Drafts</h3>'
      html += '<ul>'
      Ruhoh::DB.drafts.each_value do |draft|
        html += "<li><a href='#{draft['url']}'>#{draft['title']}</a></li>"
      end
      html += '</ul>'
      
      [200, {'Content-Type' => 'text/html'}, [html]]
    end
    
  end #Preview
  
end #Ruhoh