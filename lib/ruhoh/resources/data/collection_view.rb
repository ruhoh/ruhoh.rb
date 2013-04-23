module Ruhoh::Resources::Data
  class CollectionView < SimpleDelegator

    def initialize(collection)
      super(collection)

      # Define direct access to the dictionary Hash object
      # but don't overwrite methods if already defined.
      dictionary.keys.each do |method|
        (class << self; self; end).class_eval do
          next if method_defined?(method)
          define_method method do |*args, &block|
            dictionary[method]
          end
        end
      end
    end

    def [](attribute)
      __send__(attribute)
    end
  end
end
