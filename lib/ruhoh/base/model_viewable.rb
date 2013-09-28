module Ruhoh::Base::ModelViewable
  def initialize(model)
    super(model)
    @model = model
    @ruhoh = model.ruhoh

    # Define direct access to the data Hash object
    # but don't overwrite methods if already defined.
    data.keys.each do |method|
      (class << self; self; end).class_eval do
        next if method_defined?(method)
        define_method method do |*args, &block|
          data[method]
        end
      end
    end
  end

  def <=>(other)
    id <=> other.id
  end

  def [](attribute)
    __send__(attribute)
  end

  def []=(key, value)
    __send__("#{key}=", value)
  end
end
