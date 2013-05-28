module Ruhoh::Resources::Javascripts
  class Previewer
    include Ruhoh::SprocketsPlugin::Previewer
    def initialize(ruhoh)
      super(ruhoh.collection('javascripts'))
    end
  end
end
