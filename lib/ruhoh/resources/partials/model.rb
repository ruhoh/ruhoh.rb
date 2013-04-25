module Ruhoh::Resources::Partials
  class Model
    include Ruhoh::Base::Modelable

    def process
      return File.open(@pointer['realpath'], 'r:UTF-8') { |f| 
        return f.read
      }
    end
  end
end