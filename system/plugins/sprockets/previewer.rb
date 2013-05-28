require 'sprockets'
require 'forwardable'

module Ruhoh::SprocketsPlugin
  module Previewer
      extend Forwardable
      def_instance_delegator :@environment, :call

      def initialize(collection)
        environment = Sprockets::Environment.new
        collection.paths.reverse.each do |path|
          environment.append_path(path)
        end
        @environment = environment
      end
  end
end
