class Ruhoh::Resources::Javascripts
  class View < Ruhoh::Templaters::RMustache
    def all
      buffer = ''
      master_layout = self.context['page']['master_layout']
      sub_layout = self.context['page']['sub_layout']
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
