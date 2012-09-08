class Ruhoh
  module Templaters
    module AssetHelpers

      def assets
        method = "assets_#{@ruhoh.config.env}"
        return '' unless self.respond_to?(method)
        self.__send__(method)
      end
      
      def assets_development
        buffer = ''
        master_layout = self.context['page']['master_layout']
        sub_layout = self.context['page']['sub_layout']
        stylesheets = @ruhoh.db.stylesheets[master_layout] || []
        stylesheets += @ruhoh.db.stylesheets[sub_layout] || []
        stylesheets += @ruhoh.db.stylesheets[Ruhoh.names.widgets] || []
        stylesheets.each do |style|
          buffer += "<link href=\"#{style['url']}?#{rand()}\" type=\"text/css\" rel=\"stylesheet\" media=\"all\">\n"
        end
        buffer += "\n"
        scripts = @ruhoh.db.javascripts[master_layout] || []
        scripts += @ruhoh.db.javascripts[sub_layout] || []
        scripts += @ruhoh.db.javascripts[Ruhoh.names.widgets] || []
        scripts.each do |script|
          buffer += "<script src=\"#{script['url']}?#{rand()}\"></script>\n"
        end
        
        buffer
      end
      
      # TODO: Implement this for real.
      def assets_production
        self.assets_development
      end
      
      # NOTICE: This is unfinished and not-implemented!
      def assets_production_not_implemented
        buffer = ''
        master_layout = self.context['page']['master_layout']
        sub_layout = self.context['page']['sub_layout']
        stylesheets = []
        stylesheets << master_layout if @ruhoh.db.stylesheets[master_layout]
        stylesheets << sub_layout if @ruhoh.db.stylesheets[sub_layout]
        
        stylesheets.each do |name|
          url = [@ruhoh.urls.theme_stylesheets, "#{name}.css"].join('/')
          buffer += "<link href=\"#{url}\" type=\"text/css\" rel=\"stylesheet\" media=\"all\">\n"
        end
        buffer += "\n"
        
        scripts = []
        scripts << master_layout if @ruhoh.db.javascripts[master_layout]
        scripts << sub_layout if @ruhoh.db.javascripts[sub_layout]
        # Missing widgets
        scripts.each do |name|
          url = [@ruhoh.urls.theme_javascripts, "#{name}.js"].join('/')
          buffer += "<script src=\"#{url}\"></script>\n"
        end
        
        buffer
      end
    
    end #AssetHelpers
  end #Templaters
end #Ruhoh