module Ruhoh::Resources::Layouts
  class Modeler < Ruhoh::Resources::BaseModeler
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