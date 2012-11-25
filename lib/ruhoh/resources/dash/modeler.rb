module Ruhoh::Resources::Dash
  class Modeler < Ruhoh::Resources::Core::Base::Modeler
    include Ruhoh::Resources::Page

    def generate
      @pointer
    end
    
  end
end