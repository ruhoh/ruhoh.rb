require 'spec_helper'

module DB
  describe Ruhoh::DB do
    include_context "write_default_theme"
    include_context "default_setup"
    
    let(:whitelist){ Ruhoh::DB::WhiteList }
    context "database has not been updated" do
      it "should return nil for all whitelisted variables except payload" do
        whitelist.each do |var|
          result = @ruhoh.db.__send__(var)
          next if var == :payload
          result.should be_nil
        end
      end
    end
    
    describe "#update" do
      it "should raise an exception when updating a variable not whitelisted" do
        lambda { @ruhoh.db.update(:table) }.should raise_error
      end
      
      it "should run the site parser when updating :site, then set the variable to the result" do
        Ruhoh::Plugins::Site.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:site)
        @ruhoh.db.site.should == {'test' => 'hi'}
      end
      
      it "should run the routes parser when updating :routes" do
        Ruhoh::Plugins::Routes.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:routes)
        @ruhoh.db.routes.should == {'test' => 'hi'}
      end
      
      it "should run the posts parser when updating :posts" do
        Ruhoh::Plugins::Posts.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:posts)
        @ruhoh.db.posts.should == {'test' => 'hi'}
      end
      
      it "should run the pages parser when updating :pages" do
        Ruhoh::Plugins::Pages.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:pages)
        @ruhoh.db.pages.should == {'test' => 'hi'}
      end
      
      it "should run the layouts parser when updating :layouts" do
        Ruhoh::Plugins::Layouts.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:layouts)
        @ruhoh.db.layouts.should == {'test' => 'hi'}
      end
      
      it "should run the partials parser when updating :partials" do
        Ruhoh::Plugins::Partials.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:partials)
        @ruhoh.db.partials.should == {'test' => 'hi'}
      end
      
      it "should run the widgets parser when updating :widgets" do
        Ruhoh::Plugins::Widgets.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:widgets)
        @ruhoh.db.widgets.should == {'test' => 'hi'}
      end
      
      it "should run the stylesheets parser when updating :stylesheets" do
        Ruhoh::Plugins::Stylesheets.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:stylesheets)
        @ruhoh.db.stylesheets.should == {'test' => 'hi'}
      end

      it "should run the scripts parser when updating :javascripts" do
        Ruhoh::Plugins::Javascripts.should_receive(:generate).and_return({'test' => 'hi'})
        @ruhoh.db.update(:javascripts)
        @ruhoh.db.javascripts.should == {'test' => 'hi'}
      end
      
    end
    
    describe "#update_all" do
      it "should call update for all WhiteListed variables." do
        whitelist.each do |name|
          @ruhoh.db.should_receive(:update).with(name).ordered
        end
        @ruhoh.db.update_all
      end
    end
    
  end
  
end