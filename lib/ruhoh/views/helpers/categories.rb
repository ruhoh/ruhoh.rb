module Ruhoh::Views::Helpers
  module Categories
    def categories
      categories_url = "categories" # TODO url need to be managed by ruhoh
      dict = {}
      self.each do |item|
        Array(item.data['categories']).each do |cat|
          cat = Array(cat).join('/')
          if dict[cat]
            dict[cat]['count'] += 1
          else
            dict[cat] = { 
              'count' => 1, 
              'name' => cat, 
              item.resource => [],
              'url' => "#{categories_url}##{cat}-ref"
            }
          end 

          dict[cat][item.resource] << item.id
        end
      end  
      dict["all"] = dict.each_value.map { |cat| cat }
      dict
    end

    # Convert single or Array of category ids (names) to category hash(es).
    def to_categories(sub_context)
      Array(sub_context).map { |id|
        categories[id] 
      }.compact
    end
  end
end