module Ruhoh::Resources::Partials
  class Modeler < Ruhoh::Resources::Core::Base::Modeler
    def generate
      dict = {}
      name = @pointer['id'].chomp(File.extname(@pointer['id']))
      File.open(@pointer['realpath'], 'r:UTF-8') { |f| dict[name] = f.read }
      dict
    end
  end
end