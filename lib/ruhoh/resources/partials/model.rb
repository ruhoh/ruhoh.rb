module Ruhoh::Resources::Partials
  class Model
    include Ruhoh::Base::Modelable

    def process
      content = File.open(@pointer['realpath'], 'r:UTF-8') { |f| f.read }
      Ruhoh::Converter.convert(content, @pointer['id'])
    end
  end
end