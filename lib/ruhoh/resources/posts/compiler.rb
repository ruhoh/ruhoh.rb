require 'nokogiri'
module Ruhoh::Resources::Posts
  class Compiler < Ruhoh::Resources::Page::Compiler

    def run
      super
      rss
    end

    def rss
      num_posts = @ruhoh.db.config("posts")["rss_limit"]
      posts_view = @ruhoh.resources.load_collection_view("posts")
      posts = posts_view.all.first(num_posts)
      Ruhoh::Friend.say { cyan "Posts RSS: (first #{num_posts} posts)" }
      
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
      Ruhoh::Friend.say { green "  > seems good!" }
    end
  end
end
