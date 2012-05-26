require 'spec_helper'

module Config
  describe "Config" do
    describe "#setup_config" do
      context "Invalid _config.yml file" do
        it 'should log error and return false if theme is not specified.' do
          Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({})
          
          Ruhoh.log.should_receive(:error)
          Ruhoh::Config.generate('config.yml').should be_false
        end
      end
      context "Valid _config.yml file" do
        it 'should setup the config struct based on configuration input.' do
          custom_permalink = '/my/custom/link'
          custom_theme = 'table'
          custom_exclude = ['.secret']
          Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({
            "permalink" => custom_permalink, 
            "theme" => custom_theme,
            'exclude' => custom_exclude
          })

          config = Ruhoh::Config.generate('config.yml')
          config.theme.should == custom_theme
          config.posts_exclude.should == [/.secret/]
        end
      end
    end
    
    describe "#setup_filters" do
      it 'should add custom exclude filters to the filters variable' do
        custom_exclude = ['.secret', '^test']
        Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({
          'theme' => "twitter",
          'exclude' => custom_exclude
        })
        
        config = Ruhoh::Config.generate('config.yml')
        config.posts_exclude.should include(/.secret/)
        config.posts_exclude.should include(/^test/)
      end
    end
  end
end