module Ruhoh::Base
  class Model
    attr_reader :pointer, :ruhoh

    def initialize(ruhoh, pointer)
      @ruhoh = ruhoh
      @pointer = pointer
    end
    
    # @returns[Hash Object] Top page metadata
    def data
      return @data if @data
      process
      @data || {}
    end

    # @returns[String] Raw (unconverted) page content
    def content
      return @content if @content
      process
      @content || ''
    end

    def collection
      @ruhoh.resources.load_collection(@pointer['resource'])
    end

    # Override this to process custom data
    def process
      @pointer
    end
    
  end
end