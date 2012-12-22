module Ruhoh::Resources::Javascripts
  class CollectionView < Ruhoh::Resources::Base::CollectionView
    def all
      buffer = ''
      master_layout = master.page_data['master_layout']
      sub_layout = master.page_data['sub_layout']
      scripts = @ruhoh.db.javascripts[master_layout] || []
      scripts += @ruhoh.db.javascripts[sub_layout] || []
      scripts += @ruhoh.db.javascripts["widgets"] || []
      scripts.each do |script|
        buffer += "<script src=\"#{script['url']}?#{rand()}\"></script>\n"
      end
    
      buffer
    end
  end
end
