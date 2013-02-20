module Ruhoh::Resources::Widgets
  class CollectionView < Ruhoh::Base::CollectionView

    def widget(name)
      page_config = (master.page_data["widgets"][name] || {}) rescue {}
      config = (@collection.config[name] || {}).merge(page_config)
      return '' if config['enable'].to_s == 'false'

      pointer = @ruhoh.db.widgets["#{name}/#{(config['use'] || "default")}.html"]['pointer'] rescue nil
      return '' unless pointer

      data = @ruhoh.db.update(pointer)
      content = @ruhoh.db.content(pointer)
      view = @ruhoh.master_view('')

      # merge the config.yml data into the inline layout data.
      # Note this is reversing the normal hierarchy 
      # in that inline should always override config level.
      # However the inline in this case is set as implementation defaults 
      # and meant to be overridden by user specific data.
      view.render(content, {
        "this_config" => data.merge(config),
        "this_path" => @ruhoh.to_url(@collection.url_endpoint, name)
      })
    end

    def method_missing(name, *args, &block)
      @collection.widgets.include?(name.to_s) ? widget(name.to_s) : super
    end

    def respond_to?(method)
      @collection.widgets.include?(method.to_s) ? true : super
    end

  end
end