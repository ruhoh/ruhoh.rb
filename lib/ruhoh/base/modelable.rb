module Ruhoh::Base::Modelable
  include Observable
  
  def self.included(klass)
    klass.__send__(:attr_reader, :pointer, :ruhoh)
  end

  def initialize(ruhoh, pointer)
    raise "Cannot instantiate a model with a nil pointer" unless pointer
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
    @ruhoh.collection(@pointer['resource'])
  end

  # Override this to process custom data
  def process
    changed
    notify_observers(@pointer)
    @pointer
  end

  def try(method)
    return __send__(method) if respond_to?(method)
    return data[method.to_s] if data.key?(method.to_s)
    false
  end
end
