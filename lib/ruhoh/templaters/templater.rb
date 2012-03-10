class Ruhoh

  module Templater
    
    def self.build_payload(page)
      {
        "page"    => page.attributes,
        "site"    => Ruhoh::DB.site,
        "pages"   => Ruhoh::DB.pages,
        "_posts"  => Ruhoh::DB.posts,
        "ASSET_PATH" => Ruhoh.config.asset_path
      }
    end
    
    # Render a given page object.
    # This is different from parse only in that rendering a page
    # assumes we use page.content and its layouts as the incoming view.
    def self.render(page)
      self.parse(self.expand(page), page)
    end

    # Parse arbitrary content relative to a given page.
    def self.parse(output, page)
      Ruhoh::RMustache.render(output, self.build_payload(page))
    end
    
    # Expand the page.
    # Places page content into sub-template then into master template if available.
    def self.expand(page)
      output = page.sub_layout['content'].gsub(Ruhoh::Utils::ContentRegex, page.content)

      # An undefined master means the page/post layouts is only one deep.
      # This means it expects to load directly into a master template.
      if page.master_layout && page.master_layout['content']
        output = page.master_layout['content'].gsub(Ruhoh::Utils::ContentRegex, output);
      end
      
      output
    end
    
  end #Templater
  
end #Ruhoh