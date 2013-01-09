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
      posts_view = @ruhoh.resources.load_collection_view("posts")
      posts = posts_view.all.first(num_posts)

      feed = Nokogiri::XML::Builder.new do |xml|
       xml.rss(:version => '2.0') {
         xml.channel {
           xml.title_ @ruhoh.db.data['title']
           xml.link_ @ruhoh.config['production_url']
           xml.pubDate_ Time.now          
           posts.each do |post|
             view = @ruhoh.master_view(post.pointer)
             xml.item {
               xml.title_ post.title
               xml.link "#{@ruhoh.config['production_url']}#{post.url}"
               xml.pubDate_ post.date
               xml.description_ (post.description ? post.description : view.render_content)
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
      post_count = @ruhoh.resources.load_collection_view("posts").all.length
      total_pages = (post_count.to_f/config["per_page"]).ceil
      
      FileUtils.cd(@ruhoh.paths.compiled) {
        total_pages.times.map { |i| 
          # if a root page is defined we assume it's getting compiled elsewhere.
          next if (i.zero? && config["root_page"])

          url = "#{config["namespace"]}/#{i+1}"
          view = @ruhoh.master_view({"resource" => "posts"})
          view.page_data = {
            "layout" => @ruhoh.db.config("paginator")["layout"],
            "current_page" => (i+1),
            "url" => @ruhoh.to_url(url)
          }
          FileUtils.mkdir_p File.dirname(view.compiled_path)
          File.open(view.compiled_path, 'w:UTF-8') { |p| p.puts view.render_full }
          Ruhoh::Friend.say { green "Paginator: #{view.page_data['url']}" }
        }
      }
    end
  end
end
