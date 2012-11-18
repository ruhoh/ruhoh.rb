module Ruhoh::Templaters
  class StylesheetsHelpers < RMustache

    def all
      buffer = ''
      master_layout = self.context['page']['master_layout']
      sub_layout = self.context['page']['sub_layout']
      stylesheets = @ruhoh.db.stylesheets[master_layout] || []
      stylesheets += @ruhoh.db.stylesheets[sub_layout] || []
      stylesheets += @ruhoh.db.stylesheets["widgets"] || []
      stylesheets.each do |style|
        buffer += "<link href=\"#{style['url']}?#{rand()}\" type=\"text/css\" rel=\"stylesheet\" media=\"all\">\n"
      end
      
      buffer
    end

  end
end
