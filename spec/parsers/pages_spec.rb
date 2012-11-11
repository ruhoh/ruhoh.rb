require 'spec_helper'

module Pages
  describe Ruhoh::Plugins::Pages do
    describe "#generate" do
      include_context "write_default_theme"
      include_context "default_setup"
      
      before(:each) do
        the_pages_dir = File.join(SampleSitePath, "pages")
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
      end
      
      let(:expected_pages) {
        %w{about.md archive.html categories.html index.html pages.html sitemap.txt tags.html}.sort
      }

      let(:pages){
        Ruhoh::Plugins::Pages.generate(@pages)
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
        it "should return true for a valid page filepath" do
          filepath = 'about.md'
          Ruhoh::Plugins::Pages.is_valid_page?(filepath).should == true
        end
      
        it "should return false for a filepath beginning with ." do
          filepath = '.vim'
          Ruhoh::Plugins::Pages.is_valid_page?(filepath).should == false
        end

      end
      
      context "Exclude array is passed into config." do
        before(:each){
          Dir.mkdir SampleSitePath
          theme = "twitter"
          # Create base config.yml + base theme
          File.open(File.join(SampleSitePath, "config.yml"), "w+") { |file|
            file.puts <<-TEXT
---
theme: '#{theme}'
pages:
  exclude: ['^test', 'blah']
---  
  TEXT
          }
          theme_dir = File.join(SampleSitePath, "themes", theme)
          FileUtils.makedirs theme_dir
        }
        include_context "default_setup"
        
        it "should return false for a page filepath matching a regular expression in pages exclude array" do
          filepath1 = 'test/about.md'
          filepath2 = 'test/yay.md'
          filepath3 = 'vest/yay.md'
          Ruhoh::Plugins::Pages.is_valid_page?(filepath1).should == false
          Ruhoh::Plugins::Pages.is_valid_page?(filepath2).should == false
          Ruhoh::Plugins::Pages.is_valid_page?(filepath3).should == true
        end
      end
      
      context "Exclude string is passed into config." do
        let(:filepath){'about.md'}
        before(:each){
          Dir.mkdir SampleSitePath
          theme = "twitter"
          # Create base config.yml + base theme
          File.open(File.join(SampleSitePath, "config.yml"), "w+") { |file|
            file.puts <<-TEXT
---
theme: '#{theme}'
pages:
  exclude: '#{filepath}$'
---  
  TEXT
          }
          theme_dir = File.join(SampleSitePath, "themes", theme)
          FileUtils.makedirs theme_dir
          
          @ruhoh.setup
        }
        include_context "default_setup"
        
        it "should return false for a page whose filepath matches a page exclude regular expression." do
          Ruhoh::Plugins::Pages.is_valid_page?(filepath).should == false
        end
      end
    end

    describe "#to_title"
    describe "#permalink"
    
  end
  
end
