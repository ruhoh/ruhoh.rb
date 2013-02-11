require 'sprockets'
module Ruhoh::Resources::Stylesheets
  class Previewer
    extend Forwardable

    def_instance_delegator :@environment, :call

    def initialize(ruhoh)
      environment = Sprockets::Environment.new
      collection = ruhoh.resources.load_collection('stylesheets')
      collection.paths.reverse.each do |h|
        environment.append_path(File.join(h["path"], collection.namespace))
      end
      @environment = environment
    end
  end
end