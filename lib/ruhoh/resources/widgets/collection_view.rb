module Ruhoh::Resources::Widgets
  class CollectionView < Ruhoh::Resources::Base::CollectionView

    def widget(name)
      return '' if master.page_data[name].to_s == 'false'
      config = @ruhoh.db.config('widgets')[name] || {}
      return '' if config['enable'].to_s == 'false'
      pointer = @ruhoh.db.widgets["#{name}/#{(config['use'] || "default")}.html"]['pointer'] rescue nil
      return '' unless pointer

      model = @ruhoh.resources.model('widgets').new(@ruhoh, pointer)
      parsed = model.parse_page_file
      data = parsed['data']
      content = parsed['content']

      view = @ruhoh.master_view('')

      # merge the config.yml data into the inline layout data.
      # Note this is reversing the normal hierarchy 
      # in that inline should always override config level.
      # However the inline in this case is set as implementation defaults 
      # and meant to be overridden by user specific data.
      view.render(content, {
        "config" => data.merge(config),
        "this_path" => @ruhoh.to_url(@collection.url_endpoint, name)
      })
    end

    def method_missing(name, *args, &block)
      name = name.to_s
      @collection.widgets.include?(name) ? widget(name) : super
    end

    def respond_to?(method)
      @collection.widgets.include?(method.to_s) ? true : super
    end

  end
end