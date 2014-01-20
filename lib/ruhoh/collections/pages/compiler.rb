require 'nokogiri'
require 'ruhoh/paginator'

module Ruhoh::Collections::Pages
  class Compiler
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def run(collection_name)
      pages = @ruhoh.collections.load(collection_name)
      Ruhoh::Friend.say { cyan "#{ collection_name.capitalize }: (#{ pages.count } #{ collection_name })" }

      pages.each do |item|
        view = @ruhoh.master_view(item)
        path = @ruhoh.compiled_path_page(item.url)

        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w:UTF-8') do |p|
          p.puts(view.render_full)
        end

        Ruhoh::Friend.say { green "  > #{ item.id }" }
      end

      pagination(collection_name)
      rss(collection_name)
    end

    def pagination(collection_name)
      config = @ruhoh.config.collection(collection_name) || {}
      config = config["paginator"] || {}
      config["per_page"] ||= 5
      return unless config["enable"] == true

      Ruhoh::Friend.say { yellow "#{collection_name} paginator: enabled." }

      pages = @ruhoh.collections.load(collection_name)
      total_pages = (pages.count.to_f/config["per_page"]).ceil

      Ruhoh::Friend.say { cyan "#{collection_name} paginator: (#{ total_pages } pages)" }

      total_pages.times.each do |i|
        # if a root page is defined we assume it's getting compiled elsewhere.
        next if (i.zero? && config["root_page"])

        paginator = Ruhoh::Paginator.new(@ruhoh)
        item = paginator.item(collection_name, (i+1))

        view = @ruhoh.master_view(item)
        path = @ruhoh.compiled_path_page(item.url)

        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'w:UTF-8') do |p|
          p.puts(view.render_full)
        end
        Ruhoh::Friend.say { green "  > #{ item.url }" }
      end
    end

    def rss(collection_name)
      config = @ruhoh.config.collection(collection_name) || {}
      config = config["rss"] || {}
      config["url"] = "/#{ collection_name }"

      if config["enable"] == false
        Ruhoh::Friend.say { yellow "#{collection_name} RSS: disabled - skipping." }
        return
      end

      limit = config["limit"] || 20
      pages = @ruhoh.collections.load(collection_name)

      Ruhoh::Friend.say { cyan "#{collection_name} RSS: (first #{ limit } pages)" }

      data = @ruhoh.collections.load("data")

      feed = Nokogiri::XML::Builder.new do |xml|
       xml.rss(:version => '2.0') {
         xml.channel {
           xml.title_ data['title']
           xml.description_ (data['description'] ? data['description'] : data['title'])
           xml.link_ @ruhoh.config['production_url']
           xml.pubDate_ Time.now
           pages.each do |item|
             view = @ruhoh.master_view(item)
             xml.item {
               xml.title_ item.title
               xml.link "#{@ruhoh.config['production_url']}#{ item.url }"
               xml.pubDate_ item.data["date"] if item.data["date"]
               xml.description_ (item.data["description"] ? item.data["description"] : view.render_content)
             }
           end
         }
       }
      end

      compiled_path = @ruhoh.compiled_path(@ruhoh.to_url(config['url'], "rss.xml"))

      FileUtils.mkdir_p File.dirname(compiled_path)
      File.open(compiled_path, 'w:UTF-8')do |p| 
        p.puts(feed.to_xml)
      end

      Ruhoh::Friend.say { green "  > #{ compiled_path }" }
    end
  end
end
