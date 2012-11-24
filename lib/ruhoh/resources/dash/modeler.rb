module Ruhoh::Resources::Dash
  class Modeler < Ruhoh::Resources::BaseModeler
    include Ruhoh::Resources::Page

    def generate
      @pointer
    end
    
  end
end