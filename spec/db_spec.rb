require 'spec_helper'

module DB
  
  describe Ruhoh::DB do
    let(:whitelist){
      [:site, :routes, :posts, :pages, :layouts, :partials]
    }
    
    before(:each) do
      Ruhoh::Utils.stub(:parse_file_as_yaml).and_return({'theme' => "twitter"})
      Ruhoh.setup(SampleSitePath)
    end
    
    context "database has not been updated" do
      it "should return nil for all whitelisted variables" do
        whitelist.each do |var|
          result = Ruhoh::DB.__send__ var
          result.should be_nil
        end
      end
    end
    
    describe "#update" do
      
      it "should raise an exception when updating a variable not whitelisted" do
        lambda { Ruhoh::DB.update(:table) }.should raise_error
      end
      
      it "should run the site parser when updating :site, then set the variable to the result" do
        Ruhoh::Parsers::Site.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:site)
        Ruhoh::DB.site.should == {'test' => 'hi'}
      end
      
      it "should run the routes parser when updating :routes" do
        Ruhoh::Parsers::Routes.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:routes)
        Ruhoh::DB.routes.should == {'test' => 'hi'}
      end
      
      it "should run the posts parser when updating :posts" do
        Ruhoh::Parsers::Posts.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:posts)
        Ruhoh::DB.posts.should == {'test' => 'hi'}
      end
      
      it "should run the pages parser when updating :pages" do
        Ruhoh::Parsers::Pages.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:pages)
        Ruhoh::DB.pages.should == {'test' => 'hi'}
      end
      
      it "should run the layouts parser when updating :layouts" do
        Ruhoh::Parsers::Layouts.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:layouts)
        Ruhoh::DB.layouts.should == {'test' => 'hi'}
      end
      
      it "should run the partials parser when updating :partials" do
        Ruhoh::Parsers::Partials.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:partials)
        Ruhoh::DB.partials.should == {'test' => 'hi'}
      end
    end
    
    describe "#update!" do
      it "should call update for all WhiteListed variables." do
        Ruhoh::DB.should_receive(:update).with(:site).ordered
        Ruhoh::DB.should_receive(:update).with(:routes).ordered
        Ruhoh::DB.should_receive(:update).with(:posts).ordered
        Ruhoh::DB.should_receive(:update).with(:drafts).ordered
        Ruhoh::DB.should_receive(:update).with(:pages).ordered
        Ruhoh::DB.should_receive(:update).with(:layouts).ordered
        Ruhoh::DB.should_receive(:update).with(:partials).ordered
        Ruhoh::DB.update!
      end
    end
    
  end
  
end