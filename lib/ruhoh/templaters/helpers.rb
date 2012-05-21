require 'pp'

class Ruhoh
  module Templaters
    module Helpers
      
      def partial(name)
        p = Ruhoh::DB.partials[name.to_s]
        Ruhoh::Friend.say { yellow "partial not found: '#{name}'" } if p.nil?
        p
      end
      
      def pages
        pages = []
        self.context['db']['pages'].each_value {|page| pages << page }
        self.mark_active_page(pages)
      end
      
      def posts
        self.to_posts(self.context['db']['posts']['chronological'])
      end
      
      def categories
        cats = []
        self.context['db']['posts']['categories'].each_value { |cat| cats << cat }
        cats
      end
      
      def tags
        tags = []
        self.context['db']['posts']['tags'].each_value { |tag| tags << tag }
        tags
      end
      
      def raw_code(sub_context)
        code = sub_context.gsub('{', '&#123;').gsub('}', '&#125;').gsub('<', '&lt;').gsub('>', '&gt;')
        "<pre><code>#{code}</code></pre>"
      end
      
      def debug(sub_context)
        Ruhoh::Friend.say { 
          yellow "?debug:"
          magenta sub_context.class
          cyan sub_context.inspect
        }
        
        "<pre>#{sub_context.class}\n#{sub_context.pretty_inspect}</pre>"
      end

      def to_posts(sub_context)
        Array(sub_context).map { |id|
          self.context['db']['posts']['dictionary'][id]
        }.compact
      end

      def to_pages(sub_context)
        pages = Array(sub_context).map { |id|
          self.context['db']['pages'][id]
        }.compact
        self.mark_active_page(pages)
      end
      
      def to_categories(sub_context)
        Array(sub_context).map { |id|
          self.context['db']['posts']['categories'][id] 
        }.compact
      end
      
      def to_tags(sub_context)
        Array(sub_context).map { |id|
          self.context['db']['posts']['tags'][id] 
        }.compact
      end
      
      def next(sub_context)
        return unless sub_context.is_a?(String) || sub_context.is_a?(Hash)
        id = sub_context.is_a?(Hash) ? sub_context['id'] : sub_context
        return unless id
        index = self.context['db']['posts']['chronological'].index(id)
        return unless index && (index-1 >= 0)
        next_id = self.context['db']['posts']['chronological'][index-1]
        return unless next_id
        self.to_posts(next_id)
      end
      
      def previous(sub_context)
        return unless sub_context.is_a?(String) || sub_context.is_a?(Hash)
        id = sub_context.is_a?(Hash) ? sub_context['id'] : sub_context
        return unless id
        index = self.context['db']['posts']['chronological'].index(id)
        return unless index && (index+1 >= 0)
        prev_id = self.context['db']['posts']['chronological'][index+1]
        return unless prev_id
        self.to_posts(prev_id)
      end
            
      # Marks the active page if exists in the given pages Array
      def mark_active_page(pages)
        pages.each_with_index do |page, i| 
          next unless page['id'] == self.context[:page]['id']
          active_page = page.dup
          active_page['is_active_page'] = true
          pages[i] = active_page
        end
        pages
      end
      
    end #Helpers
  end #Templaters
end #Ruhoh