module Ruhoh::Resources::Posts
  class ModelView < Ruhoh::Resources::Page::ModelView
    # Reverse chronological order
    def <=>(other)
      Date.parse(other.date) <=> Date.parse(date)
    end
  end
end