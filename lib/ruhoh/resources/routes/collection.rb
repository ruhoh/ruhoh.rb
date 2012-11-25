module Ruhoh::Resources::Routes
  class Collection < Ruhoh::Resources::Base::Collection
    
    # Blank container for routes
    # All page objects should update the routes dictionary
    # themselves
    def generate
      {}
    end

  end
end