require 'spec_helper'

module Site
  
  describe Ruhoh::Parsers::Site do
    
    describe "#generate" do

      before(:each) do
        Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({'theme' => "twitter"})
        Ruhoh.setup(:source => SampleSitePath)
      end
      
      it 'should parse the config and site yaml files' do
        Ruhoh::Utils.should_receive(:parse_file_as_yaml).with(Ruhoh.paths.site).and_return({})
        Ruhoh::Utils.should_receive(:parse_file_as_yaml).with(Ruhoh.paths.config).and_return({})

        Ruhoh::Parsers::Site.generate
      end
      
      it 'should return a site hash with config set as value to key "config" ' do
        Ruhoh::Utils.should_receive(:parse_file_as_yaml).with(Ruhoh.paths.site).and_return({"nav" => [1,2,3]})
        Ruhoh::Utils.should_receive(:parse_file_as_yaml).with(Ruhoh.paths.config).and_return({"theme" => "orange"})
        
        site = Ruhoh::Parsers::Site.generate
        site.should == { "nav" => [1,2,3], "config" => {"theme" => "orange"} }
      end
      
    end
  end
  
end
