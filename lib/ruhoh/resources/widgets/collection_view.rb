module Ruhoh::Resources::Widgets
  class CollectionView < Ruhoh::Resources::Base::CollectionView
    

    def widget(name)
      return '' if master.data[name.to_s].to_s == 'false'
      @ruhoh.db.widgets[name.to_s]['layout']
    end

    def method_missing(name, *args, &block)
      return widget(name.to_s) if @ruhoh.db.widgets.has_key?(name.to_s)
      super
    end

    def respond_to?(method)
      return true if @ruhoh.db.widgets.has_key?(method.to_s)
      super
    end
    
  end
end
