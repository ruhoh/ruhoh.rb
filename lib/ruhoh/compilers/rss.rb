require 'nokogiri'
class Ruhoh
  module Compiler
    
    # This rss compiler is provided by David Long 
    # http://www.davejlong.com/ 
    # https://github.com/davejlong
    # Thanks David!
    class Rss
      
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
      
      def run
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
                 xml.description_ (data['description'] ? data['description'] : page.render_content)
               }
             end
           }
         }
        end
        File.open(File.join(@ruhoh.paths.compiled, 'rss.xml'), 'w'){ |p| p.puts feed.to_xml }
      end
    end
  end
end
