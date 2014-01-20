class Ruhoh
  class Paginator
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def item(collection_name, page_number)
      config = @ruhoh.config.collection(collection_name) || {}
      paginator_config = config["paginator"] || {}
      id = "#{ collection_name }/index/#{ page_number }"
      url = "/#{ id }"

      item = Silly::Item.new({ "id" => id, "cascade" => [] })
      item.collection = @ruhoh.collections.load(collection_name)
      item.content = "{{> paginator }}"
      item.data = {
        "layout" => paginator_config["layout"],
        "_url" => url,
        "title" => "#{ collection_name } page #{ page_number }"
      }

      item = Ruhoh::Collections::Pages::ModelView.new(item, @ruhoh)
      item.page_number = page_number

      item
    end
  end
end
