module Ruhoh::Resources::Stylesheets
  class CollectionView < Ruhoh::Resources::Base::CollectionView
    def all
      buffer = ''
      master_layout = master.data['master_layout']
      sub_layout = master.data['sub_layout']
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
