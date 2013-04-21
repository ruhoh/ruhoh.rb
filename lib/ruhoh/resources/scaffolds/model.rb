module Ruhoh::Resources::Scaffolds
  class Model < Ruhoh::Base::Model
    def process
      return File.open(@pointer['realpath'], 'r:UTF-8') { |f|
        return f.read
      }
    end
  end
end