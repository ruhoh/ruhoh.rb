module Ruhoh::Resources::Javascripts
  class ModelView < SimpleDelegator
    def url()
      self.collection.make_url(self.pointer['id'])
    end
  end
end
