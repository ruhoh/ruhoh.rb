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
    
    def self.process(page)
      output = page.sub_layout['content'].gsub(Ruhoh::Utils::ContentRegex, page.content)

      # An undefined master means the page/post layouts is only one deep.
      # This means it expects to load directly into a master template.
      if page.master_layout && page.master_layout['content']
        output = page.master_layout['content'].gsub(Ruhoh::Utils::ContentRegex, output);
      end
      
      self.render(output, self.build_payload(page))
    end
    
    def self.render(output, payload)
      Ruhoh::HelperMustache.render(output, payload)
    end
    
  end #Templater
  
end #Ruhoh