require 'spec_helper'

module Routes
  
  describe Ruhoh::Parsers::Routes do
    
    describe "#generate" do

      before(:each) do
        Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({'theme' => "twitter"})
        Ruhoh.setup(SampleSitePath)
      end
      
      let(:pages){
        {
          "blah.md" => {'url' => '/blah.html', "id" => "blah.md"},
          "yes.md" => {'url' => '/yes.html', "id" => "yes.md"},
          "no.md" => {'url' => '/no.html', "id" => "no.md"},
        }
      }
      let(:posts){
        { 
          "dictionary" => {
            "post1.md" => {'url' => '/post1.html', "id" => "post1.md"},
            "post2.md" => {'url' => '/post2.html', "id" => "post2.md"},
            "post3.md" => {'url' => '/post3.html', "id" => "post3.md"},
          }
        }
      }
      let(:drafts){
        {
          "draft1.md" => {'url' => '/draft1.html', "id" => "draft1.md"},
        }
      }
      
      it 'should return a dictionary/hash with urls as keys that map to post/draft/page ids as values' do
        Ruhoh::Parsers::Pages.should_receive(:generate).and_return(pages)
        Ruhoh::Parsers::Posts.should_receive(:generate).and_return(posts)
        Ruhoh::Parsers::Posts.should_receive(:generate_drafts).and_return(drafts)
        
        routes = Ruhoh::Parsers::Routes.generate
        
        routes.should be_a_kind_of(Hash)
        routes.keys.sort.should == ['/blah.html', '/draft1.html', '/no.html', '/post1.html', '/post2.html', '/post3.html', '/yes.html']
        routes.values.sort.should == ['blah.md', 'draft1.md',  'no.md', 'post1.md', 'post2.md', 'post3.md', 'yes.md']
      end

    end
  end
  
end
