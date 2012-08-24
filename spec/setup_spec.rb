require 'spec_helper'

module Setup
  describe "Setup" do
    describe "#setup" do
      it 'should setup config, paths, and filters' do
        Ruhoh::Config.should_receive(:generate).and_return(true)
        Ruhoh.setup
      end
    end
  end
end