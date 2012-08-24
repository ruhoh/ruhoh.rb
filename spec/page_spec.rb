require 'spec_helper'

module Page
  
  describe Ruhoh::Page do
    
    before(:each) do
      Ruhoh::Utils.stub(:parse_yaml_file).and_return({'theme' => "twitter"})
      Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
      
    end
    
    describe "Page initialization" do
      it "should setup default templater and converter" do
        page = Ruhoh::Page.new
        
        page.templater.should == Ruhoh::Templaters::RMustache
      end
    end

    describe "#change" do
      let(:page){ Ruhoh::Page.new }
      let(:posts) {
        {
          "dictionary" => {
            "#{Ruhoh.names.posts}/sample-id.md" => {"title" => "a cool title"}
          } 
        }
      }
      let(:pages) {
        {
          "about/index.md" => {"title" => "about me =)"}
        }
      }
      
      context "A page with invalid id" do
        it "should raise error" do
          lambda { page.change('some-id.md') }.should raise_error
        end
      end
      
      context "A page with valid id" do
        context "belonging to a post" do
          before(:all) do
            Ruhoh::Parsers::Posts.stub(:generate).and_return(posts)
            Ruhoh::DB.update(:posts)
            page.change("#{Ruhoh.names.posts}/sample-id.md")
          end
          it "should query the posts dictionary and set @data to result" do
            page.data.should == {"title" => "a cool title"}
          end
          it "should set @id to the valid id" do
            page.id.should == "#{Ruhoh.names.posts}/sample-id.md"
          end
        end
        
        context "belonging to a page" do
          before(:all) do
            Ruhoh::Parsers::Pages.stub(:generate).and_return(pages)
            Ruhoh::DB.update(:pages)
            page.change("about/index.md")
          end
          it "should query the pages dictionary and set @data to result." do
            page.data.should == {"title" => "about me =)"}
          end
          it "should set @id to the valid id" do
            page.id.should == "about/index.md"
          end
        end
        
      end

    end

    describe "#render" do
      let(:page){ Ruhoh::Page.new }
      it "should raise error if id not set" do
        lambda{ page.render }.should raise_error
      end
      
      it "should process layouts, then render using the @templater" do
        Ruhoh::DB.stub(:pages).and_return({"blah.md" => {}})
        page.change('blah.md')
        layout = "{{{content}}}"
        payload = {}
        page.should_receive(:process_layouts)
        page.should_receive(:expand_layouts).and_return(layout)
        page.should_receive(:payload).and_return(payload)
        page.templater.should_receive(:render).with(layout, payload)
        page.render
      end
    end
    
    pending "#process_layouts"

    pending "#expand_layouts"

    pending "#payload"
    
    pending "#content" do
      let(:page){ Ruhoh::Page.new }

      it "should raise error if id not set" do
        lambda{ page.content }.should raise_error
      end
      
      context "Id has been set" do
        # Set the id
        before(:all) do
          Ruhoh::DB.stub(:pages).and_return({"blah.md" => {}})
          page.change('blah.md')
        end

        it "should raise an error if the page file is malformed" do
          Ruhoh::Utils.should_receive(:parse_page_file).and_return({})
          lambda { page.content }.should raise_error
        end
      
        it "should send the files content to the templater" do
          Ruhoh::Utils.should_receive(:parse_page_file).and_return({"content" => "meep"})
          page.templater.should_receive(:parse).with("meep", page)
          page.converter.stub(:convert)
          page.content
        end
      
        it "should send the page to the converter, then set the result as @content" do
          Ruhoh::Utils.should_receive(:parse_page_file).and_return({"content" => "meep"})
          page.templater.stub(:parse)
          page.converter.should_receive(:convert).with(page).and_return("yay")
          page.content
          page.content.should == "yay"
        end
      end
    end
  
    describe "#compiled_path" do
      let(:page){ Ruhoh::Page.new }
      
      it "should raise error if id not set" do
        lambda{ page.compiled_path }.should raise_error
      end
      
      it "should return a relative filepath (no leading slash)" do
        Ruhoh::DB.stub(:pages).and_return({"blah.md" => {"url" => "/super/cool/blah-post.html"}})
        page.change('blah.md')
        page.compiled_path.should == "super/cool/blah-post.html"
      end
      
      it "should CGI.unescape the url ensure the filepath is correct." do
        Ruhoh::DB.stub(:pages).and_return({"blah.md" => {"url" => "/super/cool/%21blah-post%3D%29.html"}})
        page.change('blah.md')
        page.compiled_path.should == "super/cool/!blah-post=).html"
      end
      
      it "should specify an index.html file if url does not end in an .html extension" do
        Ruhoh::DB.stub(:pages).and_return({"blah.md" => {"url" => "/super/cool/blah-post"}})
        page.change('blah.md')
        page.compiled_path.should == "super/cool/blah-post/index.html"
      end
    end
  
  end
  
end