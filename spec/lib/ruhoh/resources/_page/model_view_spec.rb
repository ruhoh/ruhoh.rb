require 'spec_helper'

module Ruhoh::Resources::Page
  describe ModelView do
    describe "is_active_page" do
      before(:each) do
        @index_page_view = ModelView.new(nil, {:id => 'index.html'})
      end

      it "should be true if it is current page" do
        @index_page_view.master = master_with_page_data('id' => 'index.html')
        @index_page_view.is_active_page.should be_true
      end

      it "should be false if it is not current page" do
        @index_page_view.master = master_with_page_data('id' => 'some-post.html')
        @index_page_view.is_active_page.should be_false
      end

      it "should be true if it is not current page but is in breadcrumbs" do
        @index_page_view.master = master_with_page_data('id' => 'some-post.html', 'breadcrumbs' => ['index.html', 'blog.html'])
        @index_page_view.is_active_page.should be_true
      end

    end

    def master_with_page_data(page_data)
      master = Ruhoh::Views::MasterView.new(nil, nil)
      master.page_data = page_data
      master
    end
  end
end

