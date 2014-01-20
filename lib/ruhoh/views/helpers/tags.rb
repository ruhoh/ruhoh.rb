module Ruhoh::Views::Helpers
  module Tags
    def tags
      tags_url = "tags" # TODO url need to be managed by ruhoh
      dict = {}
      self.each do |item|
        Array(item.data['tags']).each do |tag|
          if dict[tag]
            dict[tag]['count'] += 1
          else
            dict[tag] = { 
              'count' => 1, 
              'name' => tag,
              item.resource => [],
              'url' => "#{tags_url}##{tag}-ref"
            }
          end 

          dict[tag][item.resource] << item.id
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