module Ruhoh::Collections::Widgets
  class CollectionView < SimpleDelegator
    attr_reader :_widgets_used
    include Ruhoh::Collectable

    def initialize(data, ruhoh=nil)
      @_widgets_used = Set.new
      @ruhoh = ruhoh

      data.each do |item|
        item.collection = self
      end

      super(data)
    end

    def widget(name)
      @_widgets_used << name.to_s
      page_config = (master.page_data["widgets"][name] || {}) rescue {}
      widget_config = (config[name] || {}).merge(page_config)
      return '' if widget_config['enable'].to_s == 'false'

      path_id = "widgets/#{ name }/#{ (widget_config['use'] || "default") }"
      model = find{ |a| a.filename == path_id }
      return '' unless model

      # merge the config data into the inline layout data.
      # Note this is reversing the normal hierarchy 
      # in that inline should always override config level.
      # However the inline in this case is set as implementation defaults 
      # and meant to be overridden by user specific data.
      master.render(model.content, {
        "this_config" => Ruhoh::Utils.deep_merge(model.data, widget_config),
        "this_path" => @ruhoh.to_url(url_endpoint, name)
      })
    end

    def url_endpoint
      "/assets/widgets"
    end


    def method_missing(name, *args, &block)
      widgets.include?(name.to_s) ? widget(name.to_s) : super
    end

    def respond_to?(method)
      widgets.include?(method.to_s) ? true : super
    end

    #@returns[Array] registered widget names.
    def widgets
      @_widgets ||= __getobj__.map{|a| a.directories[1] }
    end
  end
end
