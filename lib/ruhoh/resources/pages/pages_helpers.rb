module Ruhoh::Templaters
  class PagesHelpers < RMustache
    include PageHelpers
    
    def all
      pages = @ruhoh.db.pages.each_value.map { |val| val }
      
      mark_active_page(pages)
    end
    
  end
end