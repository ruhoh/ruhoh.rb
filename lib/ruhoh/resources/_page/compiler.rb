module Ruhoh::Resources::Page
  class Compiler < Ruhoh::Resources::Base::Compiler
    def run
      pages = @ruhoh.db.__send__(resource_name)
      resource_name = self.resource_name
      Ruhoh::Friend.say { cyan "#{resource_name.capitalize}: (#{pages.count} #{resource_name})" }
      
      FileUtils.cd(@ruhoh.paths.compiled) {
        pages.each_value { |data|
          view = @ruhoh.master_view(data['pointer'])

          FileUtils.mkdir_p File.dirname(view.compiled_path)
          File.open(view.compiled_path, 'w:UTF-8') { |p| p.puts view.render_full }

          Ruhoh::Friend.say { green "  > #{data['id']}" }
        }
      }

      pagination
    end

    def pagination
      config = @ruhoh.db.config(resource_name)["paginator"] || {}
      resource_name = self.resource_name
      if config["enable"] == false
        Ruhoh::Friend.say { yellow "#{resource_name} paginator: disabled - skipping." }
        return
      end

      pages_count = @ruhoh.resources.load_collection_view(resource_name).all.length
      total_pages = (pages_count.to_f/config["per_page"]).ceil

      Ruhoh::Friend.say { cyan "#{resource_name} paginator: (#{total_pages} pages)" }
      
      FileUtils.cd(@ruhoh.paths.compiled) {
        total_pages.times.map { |i| 
          # if a root page is defined we assume it's getting compiled elsewhere.
          next if (i.zero? && config["root_page"])

          url = "#{config["namespace"]}/#{i+1}"
          view = @ruhoh.master_view({"resource" => resource_name})
          view.page_data = {
            "layout" => config["layout"],
            "current_page" => (i+1),
            "url" => @ruhoh.to_url(url)
          }
          FileUtils.mkdir_p File.dirname(view.compiled_path)
          File.open(view.compiled_path, 'w:UTF-8') { |p| p.puts view.render_full }
          Ruhoh::Friend.say { green "  > #{view.page_data['url']}" }
        }
      }
    end
  end
end