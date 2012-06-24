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
      def self.run(target, page)
        feed = Nokogiri::XML::Builder.new do |xml|
         xml.rss(:version => '2.0') {
           xml.channel {
             xml.title_ Ruhoh::DB.site['title']
             xml.link_ Ruhoh::DB.site['config']['production_url']
             xml.pubDate_ Time.now
             Ruhoh::DB.posts['chronological'].first(Ruhoh::DB.site['config']['rss']['latest'].to_i).each do |post_id|
               post = Ruhoh::DB.posts['dictionary'][post_id]
               page.change(post_id)
               xml.item {
                 xml.title_ post['title']
                 xml.link "#{post['url']}"#.sub(Regexp.new("#{Ruhoh.urls.docroot}"), '')
                 xml.pubDate_ post['date']
                 xml.description_ (post['description'] ? post['description'] : page.render)
               }
             end
           }
         }
        end
        File.open(File.join(target, 'rss.xml'), 'w'){ |p| p.puts feed.to_xml }
      end
    end #Rss
  end #Compiler
end #Ruhoh
