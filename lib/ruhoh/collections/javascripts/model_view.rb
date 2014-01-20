module Ruhoh::Collections::Javascripts
  class ModelView < SimpleDelegator
    def initialize(item, ruhoh)
      super(item)

      @ruhoh = ruhoh
      # Define direct access to the data Hash object
      # but don't overwrite methods if already defined.
      item.data.keys.each do |method|
        (class << self; self; end).class_eval do
          next if method_defined?(method)
          define_method method do |*args, &block|
            __getobj__.data[method]
          end
        end
      end
    end

    def url
      collection.make_url(File.basename(id))
    end
  end
end
