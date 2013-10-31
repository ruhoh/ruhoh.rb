require 'spec_helper'

module Ruhoh::Plugins
  describe Initializer do
    describe 'constructor' do
      it 'raises an error when block is not defined' do
        expect { Initializer.new 'foo' }.to raise_error ArgumentError
        expect { Initializer.new('foo') { } }.to_not raise_error
      end
    end

    describe '#run' do
      it "raises an error when it's not bound" do
        initializer = Initializer.new('foo') { }
        expect { initializer.run }.to raise_error RuntimeError
        expect { initializer.bind(self).run }.to_not raise_error
      end

      it 'executes the block in the bound context' do
        initializer = Initializer.new('foo') do
          self << 'a' if length == 1
        end
        obj = ['b']
        expect { initializer.bind(obj).run }.to change(obj, :length).to 2
      end

      it 'passes given arguments to block' do
        initializer = Initializer.new('foo') do |arg|
          raise 'arg is absent' if arg != 'a'
        end
        expect { initializer.bind(self).run }.to raise_error 'arg is absent'
        expect { initializer.run 'a' }.to_not raise_error
      end
    end

    describe '#bind' do
      it 'returns self' do
        initializer = Initializer.new('foo') { }
        initializer.bind(self).should == initializer
      end
    end
  end
end