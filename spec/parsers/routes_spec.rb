require 'spec_helper'

module Routes
  
  describe Ruhoh::Resources::Routes do
    let(:ruhoh){
      Ruhoh::Utils.stub(:parse_yaml_file).and_return({'theme' => "twitter"})
      Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
      ruhoh = Ruhoh.new
      ruhoh
    }
    describe "#generate" do
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
      
      it 'should return a dictionary/hash with urls as keys that map to post/draft/page ids as values' do
        ruhoh.db.should_receive(:pages).and_return(pages)
        ruhoh.db.should_receive(:posts).and_return(posts)
        
        routes = Ruhoh::Resources::Routes.generate(ruhoh)
        
        routes.should be_a_kind_of(Hash)
        routes.keys.sort.should == ['/blah.html', '/no.html', '/post1.html', '/post2.html', '/post3.html', '/yes.html']
        routes.values.sort.should == ['blah.md',  'no.md', 'post1.md', 'post2.md', 'post3.md', 'yes.md']
      end

    end
  end
  
end
