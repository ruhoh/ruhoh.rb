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

    def self.expand_and_render(page)
      self.render(self.expand(page), page)
    end
    
    def self.render(output, page)
      Ruhoh::HelperMustache.render(output, self.build_payload(page))
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