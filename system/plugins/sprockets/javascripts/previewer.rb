require File.join(File.dirname(__FILE__), '..', 'previewer.rb')
module Ruhoh::Resources::Javascripts
  class Previewer
    include Ruhoh::SprocketsPlugin::Previewer
    def initialize(ruhoh)
      super(ruhoh.collection('javascripts'))
    end
  end
end
