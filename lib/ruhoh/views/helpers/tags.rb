module Ruhoh::Views::Helpers
  module Tags
    # Generate the tags dictionary
    def tags
      tags_url = nil
      [ruhoh.to_url("tags"), ruhoh.to_url("tags.html")].each { |url|
        tags_url = url and break if ruhoh.routes.find(url)
      }
      dict = {}
      dictionary.each_value do |model|
        Array(model.data['tags']).each do |tag|
          if dict[tag]
            dict[tag]['count'] += 1
          else
            dict[tag] = { 
              'count' => 1, 
              'name' => tag,
              resource_name => [],
              'url' => "#{tags_url}##{tag}-ref"
            }
          end 

          dict[tag][resource_name] << model.id
        end
      end  
      dict["all"] = dict.each_value.map { |tag| tag }
      dict
    end
    
    # Convert single or Array of tag ids (names) to tag hash(es).
    def to_tags(sub_context)
      Array(sub_context).map { |id|
        tags[id] 
      }.compact
    end
  end
end