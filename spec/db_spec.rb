require 'spec_helper'

module DB
  describe Ruhoh::DB do
    include_context "write_default_theme"
    include_context "default_setup"
    
    let(:whitelist){ Ruhoh::DB::WhiteList }
    context "database has not been updated" do
      it "should return nil for all whitelisted variables except payload" do
        whitelist.each do |var|
          result = Ruhoh::DB.__send__(var)
          next if var == :payload
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
      
      it "should run the widgets parser when updating :widgets" do
        Ruhoh::Parsers::Widgets.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:widgets)
        Ruhoh::DB.widgets.should == {'test' => 'hi'}
      end
      
      it "should run the stylesheets parser when updating :stylesheets" do
        Ruhoh::Parsers::Stylesheets.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:stylesheets)
        Ruhoh::DB.stylesheets.should == {'test' => 'hi'}
      end

      it "should run the scripts parser when updating :javascripts" do
        Ruhoh::Parsers::Javascripts.should_receive(:generate).and_return({'test' => 'hi'})
        Ruhoh::DB.update(:javascripts)
        Ruhoh::DB.javascripts.should == {'test' => 'hi'}
      end
      
    end
    
    describe "#update_all" do
      it "should call update for all WhiteListed variables." do
        whitelist.each do |name|
          Ruhoh::DB.should_receive(:update).with(name).ordered
        end
        Ruhoh::DB.update_all
      end
    end
    
  end
  
end