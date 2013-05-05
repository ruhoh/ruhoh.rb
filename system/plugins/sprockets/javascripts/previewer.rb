require 'sprockets'
module Ruhoh::Resources::Javascripts
  class Previewer
    extend Forwardable

    def_instance_delegator :@environment, :call

    def initialize(ruhoh)
      environment = Sprockets::Environment.new
      collection = ruhoh.collection('javascripts')
      collection.paths.reverse.each do |path|
        environment.append_path(path)
      end
      @environment = environment
    end
  end
end