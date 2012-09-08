require 'nokogiri'
class Ruhoh
  module Compiler
    # This rss compiler is provided by David Long 
    # http://www.davejlong.com/ 
    # https://github.com/davejlong
    # Thanks David!
    module Rss
      # TODO: This renders the page content even though we already need to
      # render the content to save to disk. This will be a problem when
      # posts numbers expand. Merge this in later.
      def self.run(ruhoh)
        num_posts = ruhoh.config.rss_limit
        posts = ruhoh.db.posts['chronological'].first(num_posts)

        feed = Nokogiri::XML::Builder.new do |xml|
         xml.rss(:version => '2.0') {
           xml.channel {
             xml.title_ ruhoh.db.site['title']
             xml.link_ ruhoh.db.site['config']['production_url']
             xml.pubDate_ Time.now          
             posts.each do |post_id|
               post = ruhoh.db.posts['dictionary'][post_id]
               page = ruhoh.page(post_id)
               xml.item {
                 xml.title_ post['title']
                 xml.link "#{ruhoh.db.site['config']['production_url']}#{post['url']}"
                 xml.pubDate_ post['date']
                 xml.description_ (post['description'] ? post['description'] : page.render_content)
               }
             end
           }
         }
        end
        File.open(File.join(ruhoh.paths.compiled, 'rss.xml'), 'w'){ |p| p.puts feed.to_xml }
      end
    end #Rss
  end #Compiler
end #Ruhoh
