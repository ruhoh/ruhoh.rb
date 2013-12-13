require 'spec_helper'

module Ruhoh::Plugins
  describe Plugin do
    describe '::initializers' do
      it 'returns an array' do
        Plugin.initializers.should be_a Array
      end

      it 'memoizes the array' do
        Plugin.initializers.object_id.should == Plugin.initializers.object_id
      end
    end

    context 'when included in a class' do
      let(:instance_class) do
        Class.new do
          include Plugin
        end
      end

      it 'defines the ::initializer method' do
        instance_class.should respond_to :initializer
      end

      describe '::initializer' do
        it 'appends to initializers collection' do
          expect {
            instance_class.initializer('foo') { }
          }.to change(Plugin.initializers, :length).to 1
        end

        it 'appends an initializer object filled with given params' do
          instance_class.initializer('foo') { }
          Plugin.initializers.first.name.should == 'foo'
        end
      end
    end
  end
end