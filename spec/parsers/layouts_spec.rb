require 'spec_helper'

module Layouts
  
  describe Ruhoh::Parsers::Layouts do
    
    before(:each) do
      Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({'theme' => "twitter"})
      Ruhoh.setup(SampleSitePath)
    end
    
    describe "#generate" do
      
      it 'should extract the correct layouts from a theme.' do
        layouts = Ruhoh::Parsers::Layouts.generate
        layouts.keys.sort.should == ['default', 'page', 'post']
      end
      
      it 'should return a hash for each layout containing the keys "data" and "content"' do
        layouts = Ruhoh::Parsers::Layouts.generate
        
        layouts.each_value { |value|
          value.should have_key("data")
          value.should have_key("content")
        }
      end

    end
    
  end
  
end