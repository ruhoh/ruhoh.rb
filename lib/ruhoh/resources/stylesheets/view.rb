module Ruhoh::Resources::Stylesheets
  class View < Ruhoh::Resources::Base::Collection
    def all
      buffer = ''
      master_layout = self.context['master_layout']
      sub_layout = self.context['sub_layout']
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
