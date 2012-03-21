require 'spec_helper'

module Posts
  
  describe Ruhoh::Parsers::Posts do
    
    before(:each) do
      Ruhoh::Utils.should_receive(:parse_file_as_yaml).and_return({'theme' => "twitter"})
      Ruhoh.setup(SampleSitePath)
    end
    
    describe "#generate" do
      
      it 'should return a valid data structures for core API' do
        posts = Ruhoh::Parsers::Posts.generate
        
        posts['dictionary'].should be_a_kind_of(Hash)
        posts['chronological'].should be_a_kind_of(Array)
        posts['collated'].should be_a_kind_of(Array)
        posts['tags'].should be_a_kind_of(Hash)
        posts['categories'].should be_a_kind_of(Hash)
      end
      
    end
  
    describe "#process_posts" do
      
      context "A valid post" do
        it 'should extract valid posts from source directory.' do
          dictionary, invalid = Ruhoh::Parsers::Posts.process_posts(Ruhoh.folders.posts)
          dictionary.keys.sort.should ==  ['_posts/2012-01-01-hello-world.md']
        end
        
        it 'should return a properly formatted hash for each post' do
          dictionary, invalid = Ruhoh::Parsers::Posts.process_posts(Ruhoh.folders.posts)

          dictionary.each_value { |value|
            value.should have_key("layout")
            value.should have_key("id")
            value.should have_key("url")
            value.should have_key("title")
          }
        end
      end
      
      context "A post with an invalid filename format" do
        it "should omit the post file and record it as invalid post" do
          post_path = 'test/hello-world.md'
          Dir.should_receive(:glob).and_yield(post_path)
          Ruhoh::Utils.stub(:parse_file).and_return({"data" => {"date" => "2012-01-01"}})
          
          dictionary, invalid = Ruhoh::Parsers::Posts.process_posts(Ruhoh.folders.posts)
          
          dictionary.should_not include(post_path)
          invalid[0][0].should == post_path
        end
      end
      
      context "A post with an invalid date in the filename" do
        it "should omit the post file and record it as invalid post" do
          post_path = 'test/2012-51-01-hello-world.md'
          Dir.should_receive(:glob).and_yield(post_path)
          Ruhoh::Utils.stub(:parse_file).and_return({"data" => {"title" => "meep"}})
          
          dictionary, invalid = Ruhoh::Parsers::Posts.process_posts(Ruhoh.folders.posts)
          
          dictionary.should_not include(post_path)
          invalid[0][0].should == post_path
        end
      end
      
      context "A post with an invalid date in the YAML Front Matter" do
        it "should omit the post file and record it as invalid post" do
          post_path = 'test/2012-01-01-hello-world.md'
          Dir.should_receive(:glob).and_yield(post_path)
          Ruhoh::Utils.stub(:parse_file).and_return({"data" => {"date" => "2012-51-01"}})
          
          dictionary, invalid = Ruhoh::Parsers::Posts.process_posts(Ruhoh.folders.posts)
          
          dictionary.should_not include(post_path)
          invalid[0][0].should == post_path
        end
      end
      
      context "A post with no YAML Front Matter" do
        it "should omit the post file and record it as invalid post" do
          post_path = 'test/2012-01-01-hello-world.md'
          Dir.should_receive(:glob).and_yield(post_path)
          Ruhoh::Utils.stub(:parse_file).and_return({})
          
          dictionary, invalid = Ruhoh::Parsers::Posts.process_posts(Ruhoh.folders.posts)
          
          dictionary.should_not include(post_path)
          invalid[0][0].should == post_path
        end
      end
      
    end
    
    describe "#parse_filename" do
      it "should parse a post filename into corresponding metadata" do
        filename = '_posts/2011-10-10-my-post-title.md'
        data = Ruhoh::Parsers::Posts.parse_filename(filename)

        data['path'].should == "_posts/"
        data['date'].should == "2011-10-10"
        data['slug'].should == "my-post-title"
        data['extension'].should == ".md"
      end
      
      it "should return a blank hash if the filename format is invalid" do
        filename = '_posts/my-post-title.md'
        data = Ruhoh::Parsers::Posts.parse_filename(filename)
        data.should == {}
      end
    end
    
    describe "#permalink" do
      it "should return the default permalink style (/:categories/:year/:month/:day/:title.html)" do
        post = {"date" => "2012-01-02", "title" => "My Blog Post"}
        #post = {"date" => "2012-01-02", "title" => "My Blog Post", 'permalink' => :date }
        permalink = Ruhoh::Parsers::Posts.permalink(post)
        permalink.should == '/2012/01/02/my-blog-post.html'
      end
      
      it "should return the post specific permalink style" do
        post = {"date" => "2012-01-02", "title" => "My Blog Post", 'permalink' => '/:categories/:title' }
        permalink = Ruhoh::Parsers::Posts.permalink(post)
        permalink.should == '/my-blog-post'
      end
      
      context "A post with one category" do
        it "should include the category path in the permalink." do
          post = {"date" => "2012-01-02", "title" => "My Blog Post", 'categories'=> 'ruby/lessons/beginner', 'permalink' => '/:categories/:title' }
          permalink = Ruhoh::Parsers::Posts.permalink(post)
          permalink.should == '/ruby/lessons/beginner/my-blog-post'
        end
      end
      
      context "A post belonging in two separate categories" do  
        it "should include the first category path in the permalink." do
          post = {"date" => "2012-01-02", "title" => "My Blog Post", 'categories'=> ['web', 'ruby/lessons/beginner'], 'permalink' => '/:categories/:title' }
          permalink = Ruhoh::Parsers::Posts.permalink(post)
          permalink.should == '/web/my-blog-post'
        end
      end
      
      context "A post having special characters in the title" do  
        it "should escape those characters." do
          post = {"date" => "2012-01-02", "title" => "=) My Blog Post!", 'permalink' => '/:title' }
          permalink = Ruhoh::Parsers::Posts.permalink(post)
          permalink.should_not == '/=)-my-blog-post-!'
          permalink.should == '/%3D%29-my-blog-post%21'
        end
      end
    end
    
    describe "#titleize" do
      it "should prettify a filename slug for use as a title/header" do
        file_slug = 'my-post-title'
        title = Ruhoh::Parsers::Posts.titleize(file_slug)
        title.should == "My Post Title"
      end
    end
    
    describe "helpers" do
      let(:dictionary_stub) {
        {
          "a" => {"date"=>"2011-01-01", "id" => "a"},
          "b" => {"date"=>"2011-02-01", "id" => "b"},
          "c" => {"date"=>"2012-01-01", "id" => "c"},
          "d" => {"date"=>"2010-08-01", "id" => "d"},
        }
      }
      let(:ordered_posts_stub) {
        [
          {"date"=>"2012-01-01", "id" => "c"},
          {"date"=>"2011-02-01", "id" => "b"},
          {"date"=>"2011-01-01", "id" => "a"},
          {"date"=>"2010-08-01", "id" => "d"},
        ]
      }
      let(:collated_stub) {
        [
          {"year"=>"2012", "months"=>[{"month"=>"January", "posts"=>["c"]}]},
          {"year"=>"2011", "months"=>[{"month"=>"February", "posts"=>["b"]}, {"month"=>"January", "posts"=>["a"]}]},
          {"year"=>"2010", "months"=>[{"month"=>"August", "posts"=>["d"]}]}
        ]
      }
      
      describe "#ordered_posts" do
        it "should order a dictionary hash by date descending and return an Array" do
          ordered_posts = Ruhoh::Parsers::Posts.ordered_posts(dictionary_stub)

          ordered_posts.should be_a_kind_of(Array)
          ordered_posts.should == ordered_posts_stub
        end
      end

      describe "#build_chronology" do
        it 'should return an array of ids ordered by date descending' do
          chrono = Ruhoh::Parsers::Posts.build_chronology(ordered_posts_stub)
          chrono.should == ['c', 'b', 'a', 'd']
        end
      end
      
      describe "#collate" do
        it 'should return an array of years with nested months and nested, ordered post ids for each month.' do
          collated = Ruhoh::Parsers::Posts.collate(ordered_posts_stub)
          collated.should == collated_stub
        end
      end
      
    end
    
    describe "#parse_tags" do
      let(:ordered_posts_stub) {
        [
          {"id" => "c", "tags" => ['apple', 'orange']},
          {"id" => "b", "tags" => ['apple', 'pear']},
          {"id" => "a", "tags" => ['banana']},
          {"id" => "d", "tags" => 'kiwi' },
        ]
      }
      let(:tags){
        Ruhoh::Parsers::Posts.parse_tags(ordered_posts_stub)
      }
      
      it 'should return a dictionary of all tags on posts' do
        tags.keys.sort.should == ['apple', 'banana', 'kiwi', 'orange', 'pear']
      end
      
      it 'should return a dictionary containing tag objects having name, count and posts' do
        tags.each_value { |tag|
          tag.should have_key("name")
          tag.should have_key("count")
          tag.should have_key("posts")
        }
      end
      
      it 'should return a dictionary with tag objects having correct post id references.' do
        tags['apple']['posts'].should == ['c', 'b']
        tags['banana']['posts'].should == ['a']
        tags['kiwi']['posts'].should == ['d']
        tags['orange']['posts'].should == ['c']
        tags['pear']['posts'].should == ['b']
      end
      
      it 'should return a dictionary containing correct tag counts' do
        tags['apple']['count'].should == 2
        tags['banana']['count'].should == 1
        tags['kiwi']['count'].should == 1
        tags['orange']['count'].should == 1
        tags['pear']['count'].should == 1
      end
      
    end
    
    describe "#parse_categories" do
      let(:ordered_posts_stub) {
        [
          {"id" => "c", "categories" => ['web', ['ruby', 'tutorials']] },
          {"id" => "b", "categories" => ['web', ['ruby']] },
          {"id" => "a", "categories" => ['web', 'python'] },
          {"id" => "d", "categories" => 'erlang' },
        ]
      }

      let(:categories) {
        categories = Ruhoh::Parsers::Posts.parse_categories(ordered_posts_stub)
      }

      it 'should return a dictionary of all post categories' do
        categories.keys.sort.should == ['erlang', 'python', 'ruby', 'ruby/tutorials', 'web']
      end
      
      it 'should return a dictionary containing category objects having name, count and posts' do
        categories.each_value { |cat|
          cat.should have_key("name")
          cat.should have_key("count")
          cat.should have_key("posts")
        }
      end
      
      it 'should return a dictionary with category objects having correct post id references.' do
        categories['erlang']['posts'].should == ['d']
        categories['python']['posts'].should == ['a']
        categories['ruby']['posts'].should == ['b']
        categories['ruby/tutorials']['posts'].should == ['c']
        categories['web']['posts'].should == ['c','b','a']
      end
      
      it 'should return a dictionary containing correct tag counts' do
        categories['erlang']['count'].should == 1
        categories['python']['count'].should == 1
        categories['ruby']['count'].should == 1
        categories['ruby/tutorials']['count'].should == 1
        categories['web']['count'].should == 3
      end
      
    end
    
  end
  
end