class Ruhoh::Resources::Pages
  class View < Ruhoh::Views::RMustache
    include Ruhoh::Views::Helpers::Page
    
    def all
      pages = @ruhoh.db.pages.each_value.map { |val| val }
      pages = mark_active_page(pages)
      pages.map {|data|
        model = Single.new(@ruhoh, data)
        model.collection = self
        model.master = context['master']
        model
      }
    end
    
    class Single < Ruhoh::Views::Helpers::Page::Single
      
    end
    
  end
end
