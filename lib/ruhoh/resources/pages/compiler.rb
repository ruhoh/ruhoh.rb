require 'nokogiri'
module Ruhoh::Resources::Pages
  class Compiler
    include Ruhoh::Base::Compilable

    def run
      pages = @collection.all
      resource_name = @collection.resource_name
      Ruhoh::Friend.say { cyan "#{resource_name.capitalize}: (#{pages.count} #{resource_name})" }
      pages.each do |data|
        view = @ruhoh.master_view(data['pointer'])

        FileUtils.mkdir_p File.dirname(view.compiled_path)
        File.open(view.compiled_path, 'w:UTF-8') { |p| p.puts view.render_full }

        Ruhoh::Friend.say { green "  > #{data['id']}" }
      end


      pagination
      rss
    end

    def pagination
      config = @collection.config["paginator"] || {}
      resource_name = @collection.resource_name
      if config["enable"] == false
        Ruhoh::Friend.say { yellow "#{resource_name} paginator: disabled - skipping." }
        return
      end

      pages_count = @collection.all.length
      total_pages = (pages_count.to_f/config["per_page"]).ceil

      Ruhoh::Friend.say { cyan "#{resource_name} paginator: (#{total_pages} pages)" }

      total_pages.times.map { |i| 
        # if a root page is defined we assume it's getting compiled elsewhere.
        next if (i.zero? && config["root_page"])

        url = "#{config["url"]}/#{i+1}"
        view = @ruhoh.master_view({"resource" => resource_name})
        view.page_data = {
          "layout" => config["layout"],
          "current_page" => (i+1),
          "total_pages" => total_pages,
          "url" => @ruhoh.to_url(url)
        }
        FileUtils.mkdir_p File.dirname(view.compiled_path)
        File.open(view.compiled_path, 'w:UTF-8') { |p| p.puts view.render_full }
        Ruhoh::Friend.say { green "  > #{view.page_data['url']}" }
      }
    end

    def rss
      config = @collection.config["rss"] || {}
      resource_name = @collection.resource_name
      if config["enable"] == false
        Ruhoh::Friend.say { yellow "#{resource_name} RSS: disabled - skipping." }
        return
      end

      limit = config["limit"] || 20
      pages = @collection.all.first(limit)
      Ruhoh::Friend.say { cyan "#{resource_name} RSS: (first #{limit} pages)" }
      data = @ruhoh.collection("data").dictionary

      feed = Nokogiri::XML::Builder.new do |xml|
       xml.rss(:version => '2.0') {
         xml.channel {
           xml.title_ data['title']
           xml.description_ (data['description'] ? data['description'] : data['title'])
           xml.link_ production_url
           xml.pubDate_ Time.now.strftime '%a, %d %b %Y %H:%M:%S %z'
           pages.each do |page|
             view = @ruhoh.master_view(page.pointer)
             xml.item {
               xml.title_ page.title
               xml.link "#{production_url}#{page.url}"
               xml.pubDate_ page.date.strftime '%a, %d %b %Y %H:%M:%S %z' if page.date
               xml.description_ with_absolute_urls(page.try(:description) ? page.description : view.render_content)
             }
           end
         }
       }
      end

      compiled_path = @ruhoh.compiled_path(@ruhoh.to_url(config['url'], "rss.xml"))

      FileUtils.mkdir_p File.dirname(compiled_path)
      File.open(compiled_path, 'w'){ |p| p.puts feed.to_xml }

      Ruhoh::Friend.say { green "  > #{compiled_path}" }
    end

    private

    def with_absolute_urls(content_html)
      doc = Nokogiri::HTML::DocumentFragment.parse(content_html)
      doc.xpath("*[@href|@src]|*//*[@href|@src]").each do |tag|
        fix_url_in(tag, 'href') || fix_url_in(tag, 'src')
      end
      doc.to_s
    end

    def absolutify_url(url)
      URI.join(production_url, url)
    end

    def production_url
      @ruhoh.config['production_url']
    end

    def fix_url_in(tag, attribute)
      return unless tag[attribute]
      tag[attribute] = absolutify_url(tag[attribute])
    end
  end
end
