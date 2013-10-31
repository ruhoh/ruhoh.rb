module Ruhoh::Plugins
  class Initializer
    attr_reader :name

    def initialize name, &block
      raise ArgumentError, "block required for initializer '#{name}'" unless block_given?
      @name, @block = name, block
    end

    def run *args
      raise "Initializer '#{name}' need to be bound" unless context
      context.instance_exec *args, &block
    end

    def bind ctx
      @context = ctx
      self
    end

    private

    attr_reader :block, :context
  end
end