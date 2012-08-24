require 'spec_helper'

module Site
  
  describe Ruhoh::Parsers::Site do
    include_context "write_default_theme"
    include_context "default_setup"
    
    describe "#generate" do
      it 'should parse the config and site yaml files' do
        Ruhoh::Utils.should_receive(:parse_yaml_file).with(Ruhoh.paths.site_data).and_return({})
        Ruhoh::Utils.should_receive(:parse_yaml_file).with(Ruhoh.paths.config_data).and_return({})

        Ruhoh::Parsers::Site.generate
      end
      
      it 'should return a site hash with config set as value to key "config" ' do
        Ruhoh::Utils.should_receive(:parse_yaml_file).with(Ruhoh.paths.site_data).and_return({"nav" => [1,2,3]})
        Ruhoh::Utils.should_receive(:parse_yaml_file).with(Ruhoh.paths.config_data).and_return({"theme" => "orange"})
        
        site = Ruhoh::Parsers::Site.generate
        site.should == { "nav" => [1,2,3], "config" => {"theme" => "orange"} }
      end
      
    end
  end
  
end
