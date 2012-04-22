require 'spec_helper'

module Pages
  
  describe Ruhoh::Parsers::Pages do
    
    describe "#generate" do
      
      before(:each) do
        Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({'theme' => "twitter"})
        Ruhoh.setup(:source => SampleSitePath)
      end
      
      let(:pages){
        Ruhoh::Parsers::Pages.generate
      }
      
      it 'should extract valid pages from source directory.' do
        pages.keys.sort.should ==  ['about.md', 'archive.html', 'categories.html', 'index.html', 'pages.html', 'sitemap.txt', 'tags.html']
      end
      
      it 'should return a properly formatted hash for each page' do
        pages.each_value { |value|
          value.should have_key("id")
          value.should have_key("url")
          value.should have_key("title")
        }
      end

    end
    
    describe "#is_valid_page?" do
      
      context "No user specified exclusions in config." do
        
        before(:each) do
          Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({'theme' => "twitter"})
          Ruhoh.setup(:source => SampleSitePath)
        end
        
        it "should return true for a valid page filepath" do
          filepath = 'about.md'
          Ruhoh::Parsers::Pages.is_valid_page?(filepath).should == true
        end
      
        it "should return false for a filepath beginning with ." do
          filepath = '.vim'
          Ruhoh::Parsers::Pages.is_valid_page?(filepath).should == false
        end

      end
      
      context "Exclude array is passed into config." do
        
        it "should return false for a filepath matching a string in exclude array" do
          filepath = 'about.md'
          Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({
            'theme' => "twitter",
            'exclude' => filepath
          })
          Ruhoh.setup(:source => SampleSitePath)
          
          Ruhoh::Parsers::Pages.is_valid_page?(filepath).should == false
        end
        
        it "should return false for a filepath matching a regular expression in exclude array" do
          filepath1 = 'test/about.md'
          filepath2 = 'test/yay.md'
          filepath3 = 'vest/yay.md'
          Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({
            'theme' => "twitter",
            'exclude' => /^test/
          })
          Ruhoh.setup(:source => SampleSitePath)
          
          Ruhoh::Parsers::Pages.is_valid_page?(filepath1).should == false
          Ruhoh::Parsers::Pages.is_valid_page?(filepath2).should == false
          Ruhoh::Parsers::Pages.is_valid_page?(filepath3).should == true
        end
        
      end
      
    end
    
    
    describe "#titleize"
    describe "#permalink"
    
  end
  
end