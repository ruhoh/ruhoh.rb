module Ruhoh::Resources::Stylesheets
  class Previewer
    include Ruhoh::SprocketsPlugin::Previewer
    def initialize(ruhoh)
      super(ruhoh.collection('stylesheets'))
    end
  end
end
