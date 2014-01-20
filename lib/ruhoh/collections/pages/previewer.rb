require 'ruhoh/ui/page_not_found'
require 'ruhoh/paginator'

# Public: Rack application used to render singular pages via their URL.
module Ruhoh::Collections::Pages
  class Previewer

    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def call(env)
      return favicon if env['PATH_INFO'] == '/favicon.ico'

      # Always remove trailing slash if sent unless it's the root page.
      env['PATH_INFO'].chomp!("/") unless env['PATH_INFO'] == "/"

      item = find_page(env)

      if item
        view = @ruhoh.master_view(item)

        Ruhoh::Friend.say {
          plain "- previewing page:"
          plain "   #{ item.id }"
        }
        [200, {'Content-Type' => 'text/html'}, [view.render_full]]
      else
        Ruhoh::UI::PageNotFound.new(@ruhoh, item).call(env)
      end
    end

    def find_page(env)
      parts = env['PATH_INFO'].split("/") ; parts.shift

      query = @ruhoh.query
      if parts.count > 1
        query = query.path(parts[0])
      else
        query = query.path("_root")
      end

      last_element = parts.last.to_s
      last_element = last_element.empty? ? "index" : last_element.split('.')[0]
      query = query.where("$shortname" => last_element)

      # Handle literal cases where the url is the name of the file.
      if (item = query.first)
        return Ruhoh::Collections::Pages::ModelView.new(item, @ruhoh)
      end

      collections = @ruhoh.query.list

      easy = []
      hard = []
      @ruhoh.config.each do |key, value| 
        next if (!value.respond_to?(:[]) || value["permalink"].to_s.empty?)
        data = { "collection" => key, "permalink" => value["permalink"] }

        if value["permalink"].start_with?(":")
          hard << data
        else
          easy << data
        end
      end

      # Handle easy cases -- where permalinks start with static namespace
      # and can be looked up via the collection folder.
      # FIXME  this won't work for stuff like: jade/, jade-beans/ =(
      # build permalink prefix with preceeding slash included and omitted.
      prefix = parts.first
      prefix = prefix.start_with?('/') ? prefix : "/#{ prefix }"
      match = easy.find { |data| data["permalink"].start_with?(prefix, prefix[1, prefix.length-1]) }
      if match
        item = @ruhoh.query.path(match["collection"]).where("_url" => "/#{ parts.join("/") }").first

        if item
          return Ruhoh::Collections::Pages::ModelView.new(item, @ruhoh)
        end
      end

      # Try the paginator
      item = paginator_item(parts)
      return item if item

      # TODO: Handle hard cases -- where permalinks start with a variable so can be anything.
    end

    # Try the paginator.
    def paginator_item(parts)
      collection_name = @ruhoh.query.list.find{ |a| a == parts[0] }
      return false unless collection_name
      page_number = parts.last.match(/([1-9]+)/)[0] rescue nil
      return false if page_number.to_i.zero?

      paginator = Ruhoh::Paginator.new(@ruhoh)
      paginator.item(collection_name, page_number)
    end

    def favicon
      [200, {'Content-Type' => 'image/x-icon'}, ['']]
    end
  end
end
