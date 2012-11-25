module Ruhoh::Resources::Scaffolds
  class Model < Ruhoh::Resources::Base::Model
    def generate
      dict = {}
      File.open(@pointer['realpath'], 'r:UTF-8') { |f| dict[@pointer['id']] = f.read }
      dict
    end
  end
end