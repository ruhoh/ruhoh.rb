require 'spec_helper'

module Pages
  
  describe Ruhoh::Parsers::Pages do
    
    describe "#generate" do
      
      before(:each) do
        Ruhoh::Utils.should_receive(:parse_yaml_file).and_return({'theme' => "twitter"})
        the_pages_dir = File.join(SampleSitePath, Ruhoh.names.pages)
        FileUtils.remove_dir(the_pages_dir, 1) if Dir.exists? the_pages_dir
        Dir.mkdir the_pages_dir
        expected_pages.each do |page_name| 
          full_file_name = File.join(the_pages_dir, page_name)
          File.open full_file_name, "w+" do |file|
            file.puts <<-TEXT
---
title: #{page_name} (test)
---  
            TEXT
          end
        end
        
        Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
        Ruhoh.setup(:source => SampleSitePath)
      end
      
      let(:expected_pages) {
        %w{about.md archive.html categories.html index.html pages.html sitemap.txt tags.html}.sort
      }

      let(:pages){
        Ruhoh::Parsers::Pages.generate
      }
      
      it 'should extract valid pages from source directory.' do
        pages.keys.sort.should == expected_pages
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
          Ruhoh::Utils.should_receive(:parse_yaml_file).and_return({'theme' => "twitter"})
          Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
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
        
        it "should return false for a page whose filepath matches a page exclude regular expression." do
          filepath = 'about.md'
          Ruhoh::Utils.should_receive(:parse_yaml_file).and_return({
            'theme' => "twitter",
            'pages' => {'exclude' => "#{filepath}$"}
          })
          Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
          Ruhoh.setup(:source => SampleSitePath)
          Ruhoh::Parsers::Pages.is_valid_page?(filepath).should == false
        end
        
        it "should return false for a page filepath matching a regular expression in pages exclude array" do
          filepath1 = 'test/about.md'
          filepath2 = 'test/yay.md'
          filepath3 = 'vest/yay.md'
          Ruhoh::Utils.should_receive(:parse_yaml_file).and_return({
            'theme' => "twitter",
            'pages' => {'exclude' => ['^test', 'blah'] }
          })
          Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
          Ruhoh.setup(:source => SampleSitePath)
          
          Ruhoh::Parsers::Pages.is_valid_page?(filepath1).should == false
          Ruhoh::Parsers::Pages.is_valid_page?(filepath2).should == false
          Ruhoh::Parsers::Pages.is_valid_page?(filepath3).should == true
        end
        
      end
      
    end
    
    
    describe "#to_title"
    describe "#permalink"
    
  end
  
end
