require 'nokogiri'
module Ruhoh::Resources::Posts
  class Compiler < Ruhoh::Resources::Page::Compiler
    
    def run
      super
      rss
      pagination
    end
    
    def rss
      Ruhoh::Friend.say { green "Generating RSS for posts." }
      num_posts = @ruhoh.db.config("posts")["rss_limit"]
      posts = @ruhoh.db.posts.each_value.map { |val| val }
      posts.sort! {
        |a,b| Date.parse(b['date']) <=> Date.parse(a['date'])
      }
      posts = posts.first(num_posts)

      feed = Nokogiri::XML::Builder.new do |xml|
       xml.rss(:version => '2.0') {
         xml.channel {
           xml.title_ @ruhoh.db.site['title']
           xml.link_ @ruhoh.config['production_url']
           xml.pubDate_ Time.now          
           posts.each do |data|
             page = @ruhoh.page(data["pointer"])
             xml.item {
               xml.title_ data['title']
               xml.link "#{@ruhoh.config['production_url']}#{data['url']}"
               xml.pubDate_ data['date']
               xml.description_ (data['description'] ? data['description'] : page.render_full)
             }
           end
         }
       }
      end
      compiled_path = CGI.unescape(@ruhoh.config['base_path'] + 'rss.xml')
      File.open(File.join(@ruhoh.paths.compiled, compiled_path), 'w'){ |p| p.puts feed.to_xml }
    end
    
    # This is post specific at the moment but probably should
    # be abstracted out into paginator resource is possible.
    def pagination
      config = @ruhoh.db.config("paginator")
      post_count = @ruhoh.db.posts.length
      total_pages = (post_count.to_f/config["per_page"]).ceil
      
      FileUtils.cd(@ruhoh.paths.compiled) {
        total_pages.times.map { |i| 
          next if i.zero? # handled by config["root_page"]
          url = "#{config["namespace"]}#{i+1}"
          page = @ruhoh.page({"resource" => "posts"})
          page.data = {
            "layout" => @ruhoh.db.config("paginator")["layout"],
            "current_page" => (i+1),
            "url" => @ruhoh.to_url(url)
          }
          FileUtils.mkdir_p File.dirname(page.compiled_path)
          File.open(page.compiled_path, 'w:UTF-8') { |p| p.puts page.render_full }
          Ruhoh::Friend.say { green "Paginator: #{page.data['url']}" }
        }
      }
    end
  end
end
