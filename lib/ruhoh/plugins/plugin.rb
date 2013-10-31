require 'ruhoh/plugins/initializer'

module Ruhoh::Plugins
  module Plugin
    def self.included base
      base.send :extend, ClassMethods
    end

    def self.run_all(context, *args)
      initializers.each do |i|
        i.bind(context).run *args
      end
    end

    protected

    def self.initializers
      @initializers ||= []
    end

    module ClassMethods
      def initializer name, &block
        Plugin.initializers << Initializer.new(name, &block)
      end
    end
  end
end