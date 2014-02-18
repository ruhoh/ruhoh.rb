require 'sprockets'
require 'forwardable'

module Ruhoh::SprocketsPlugin
  module Previewer
      extend Forwardable
      def_instance_delegator :@environment, :call

      def initialize(cascade)
        environment = Sprockets::Environment.new
        cascade.each do |path|
          environment.append_path(path)
        end
        @environment = environment
      end
  end
end
