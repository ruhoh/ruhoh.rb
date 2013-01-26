require 'sprockets'
module Ruhoh::Resources::Stylesheets
  class Previewer
    extend Forwardable

    def_instance_delegator :@environment, :call

    def initialize(ruhoh)
      collection = ruhoh.resources.load_collection('stylesheets')
      environment = Sprockets::Environment.new
      environment.append_path(collection.path)
      @environment = environment
    end
  end
end