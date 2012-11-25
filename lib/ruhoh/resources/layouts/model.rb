module Ruhoh::Resources::Layouts
  class Model < Ruhoh::Resources::Base::Model
    def generate
      dict = {}
      id = File.basename(@pointer['id'], File.extname(@pointer['id']))
      data = Ruhoh::Utils.parse_layout_file(@pointer['realpath'])
      data['id'] = id
      dict[id] = data
      dict
    end
  end
end