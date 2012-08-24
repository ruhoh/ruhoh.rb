require 'spec_helper'
module Layouts
  describe Ruhoh::Parsers::Layouts do
    
    before(:each) do
      expected_theme = "twitter"
      the_layouts_dir = File.join(SampleSitePath, Ruhoh.names.themes, expected_theme, Ruhoh.names.layouts)
      FileUtils.makedirs the_layouts_dir
      expected_layouts.each do |layout_name| 
        full_file_name = File.join(the_layouts_dir, layout_name)
        
        File.open full_file_name, "w+" do |file|
          file.puts <<-TEXT
---
title: #{layout_name} (test)
---  
          TEXT
        end
      end
    end

    let(:expected_layouts) { %w{default.html page.html post.html} }
    
    describe "#generate" do
      let(:layouts){
        Ruhoh::Parsers::Layouts.generate
      }
      
      it 'should extract the correct layouts from a theme.' do
        layouts.keys.sort.should == ['default', 'page', 'post']
      end
      
      it 'should return a hash for each layout containing the keys "data" and "content"' do
        layouts.each_value { |value|
          value.should have_key("data")
          value.should have_key("content")
        }
      end
    end
  end
end