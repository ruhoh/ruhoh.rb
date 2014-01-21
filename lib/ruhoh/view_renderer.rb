require 'ruhoh/views/helpers/simple_proxy'
require 'ruhoh/views/context'
require 'ruhoh/views/mustache_renderer'
require 'ruhoh/views/erb_renderer'
require 'ruhoh/views/haml_renderer'

module Ruhoh::Views
  class Renderer
    def initialize(ruhoh, item)
      @ruhoh = ruhoh
      @item = item
    end

    def render_content
      view_class(@item.ext).render({
        ruhoh: @ruhoh,
        item: @item,
        template: @item.content,
        content: ""
      })
    end

    def render_full
      if page_layouts.empty?
        render_content
      else
        page_layouts.reduce(render_content) do |c, l|
          view_class(l.ext).render({
            ruhoh: @ruhoh,
            item: @item,
            template: l.content,
            content: c
          })
        end
      end
    end

    private

    def page_layouts
      return @page_layouts unless @page_layouts.nil?

      layout = if @item.data['layout']
        @ruhoh.query.path("layouts").where("$shortname" => @item.data['layout']).first or raise "Layout does not exist: #{@item.data['layout']}"
      elsif @item.data['layout'] != false
        # try collection default
        layout_name = @ruhoh.config.collection(@item.resource)["layout"] || @item.resource
        @ruhoh.query.path("layouts").where("$shortname" => layout_name).first
      end

      @page_layouts = if layout.nil?
        []
      else
        page_layouts = [layout]
        until layout.data["layout"].nil?
          layout = @ruhoh.query.path("layouts").where("$shortname" => layout.data["layout"]).first or raise "Layout does not exist: #{ layout.data["layout"] }"

          raise "Layout cycle detected when rendering #{@item}: \n #{
            (page_layouts << layout).map{ |l| l.realpath }.join("\n")
          }" if page_layouts.include?(layout)

          page_layouts << layout
        end
        page_layouts
      end
    end

    def view_class(ext)
      if ext == ".erb"
        Ruhoh::Views::ErbRenderer
      elsif ext == ".haml"
        Ruhoh::Views::HamlRenderer
      else
        Ruhoh::Views::MustacheRenderer
      end
    end
  end
end
