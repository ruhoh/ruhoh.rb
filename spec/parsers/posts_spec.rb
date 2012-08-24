# encoding: utf-8
require 'spec_helper'

module Posts
  describe Ruhoh::Parsers::Posts do
    include_context "write_default_theme"
    include_context "default_setup"
    
    pending "#generate" do
      
      it 'should return a valid data structures for core API' do
        posts = Ruhoh::Parsers::Posts.generate
        
        posts['dictionary'].should be_a_kind_of(Hash)
        posts['chronological'].should be_a_kind_of(Array)
        posts['collated'].should be_a_kind_of(Array)
        posts['tags'].should be_a_kind_of(Hash)
        posts['categories'].should be_a_kind_of(Hash)
      end
      
    end
  
    describe "#process" do
      
      context "A valid post" do
        pending 'should extract valid posts from source directory.' do
          Ruhoh::Parsers::Posts.process
          dictionary.keys.sort.should ==  ['_posts/2012-01-01-hello-world.md']
        end
        
        pending 'should return a properly formatted hash for each post' do
          dictionary = Ruhoh::Parsers::Posts.process

          dictionary.each_value { |value|
            value.should have_key("id")
            value.should have_key("url")
            value.should have_key("title")
          }
        end
      end
      
      context "A post with an invalid filename format" do
        it "should omit the post file and record it as invalid post" do
          post_path = 'test/hello-world.md'
          Ruhoh::Parsers::Posts.should_receive(:files).and_return([post_path])
          Ruhoh::Utils.stub(:parse_page_file).and_return({"data" => {"date" => "2012-01-01"}})
          
          dictionary = Ruhoh::Parsers::Posts.process
          
          dictionary.should_not include(post_path)
        end
      end
      
      context "A post with an invalid date in the filename" do
        it "should omit the post file and record it as invalid post" do
          post_path = 'test/2012-51-01-hello-world.md'
          Ruhoh::Parsers::Posts.should_receive(:files).and_return([post_path])
          Ruhoh::Utils.stub(:parse_page_file).and_return({"data" => {"title" => "meep"}})
          
          dictionary = Ruhoh::Parsers::Posts.process
          
          dictionary.should_not include(post_path)
        end
      end
      
      context "A post with an invalid date in the YAML Front Matter" do
        it "should omit the post file and record it as invalid post" do
          post_path = 'test/2012-01-01-hello-world.md'
          Ruhoh::Parsers::Posts.should_receive(:files).and_return([post_path])
          Ruhoh::Utils.stub(:parse_page_file).and_return({"data" => {"date" => "2012-51-01"}})
          
          dictionary = Ruhoh::Parsers::Posts.process
          
          dictionary.should_not include(post_path)
        end
      end
    end
    
    describe "#parse_page_filename" do
      it "should parse a post filename with DATE into corresponding metadata" do
        filename = '_posts/2011-10-10-my-post-title.md'
        data = Ruhoh::Parsers::Posts.parse_page_filename(filename)

        data['path'].should == "_posts/"
        data['date'].should == "2011-10-10"
        data['slug'].should == "my-post-title"
        data['extension'].should == ".md"
      end
      
      it "should parse a post filename without DATE into corresponding metadata" do
        filename = '_posts/my-post-title.md'
        data = Ruhoh::Parsers::Posts.parse_page_filename(filename)
        data['path'].should == "_posts/"
        data['date'].should == nil
        data['slug'].should == "my-post-title"
        data['extension'].should == ".md"
      end
      
      it "should return a blank hash if the filename has no extension and therefore invalid" do
        filename = '_posts/my-post-title'
        data = Ruhoh::Parsers::Posts.parse_page_filename(filename)
        data.should == {}
      end
    end
    
    describe "#permalink" do
      it "should return the default permalink style (/:categories/:year/:month/:day/:title.html)" do
        post = {"date" => "2012-01-02", "title" => "My Blog Post", "id" => "my-blog-post.md"}
        permalink = Ruhoh::Parsers::Posts.permalink(post)
        permalink.should == '/2012/01/02/my-blog-post.html'
      end
      
      it "should return the post specific permalink style" do
        post = {"id" => "my-blog-post.md", "date" => "2012-01-02", "title" => "My Blog Post", 'permalink' => '/:categories/:title' }
        permalink = Ruhoh::Parsers::Posts.permalink(post)
        permalink.should == '/my-blog-post'
      end
      
      context "A post with one category" do
        it "should include the category path in the permalink." do
          post = {"id" => "my-blog-post.md", "date" => "2012-01-02", "title" => "My Blog Post", 'categories'=> 'ruby/lessons/beginner', 'permalink' => '/:categories/:title' }
          permalink = Ruhoh::Parsers::Posts.permalink(post)
          permalink.should == '/ruby/lessons/beginner/my-blog-post'
        end
      end
      
      context "A post belonging in two separate categories" do  
        it "should include the first category path in the permalink." do
          post = {"id" => "my-blog-post.md", "date" => "2012-01-02", "title" => "My Blog Post", 'categories'=> ['web', 'ruby/lessons/beginner'], 'permalink' => '/:categories/:title' }
          permalink = Ruhoh::Parsers::Posts.permalink(post)
          permalink.should == '/web/my-blog-post'
        end
      end
      
      context "A post with a literal permalink" do  
        it "should use the literal permalink" do
          post = {"id" => "my-blog-post.md", "date" => "2012-01-02", "title" => "=) My Blog Post!", 'permalink' => '/dogs/and/cats/summer-pictures' }
          permalink = Ruhoh::Parsers::Posts.permalink(post)
          permalink.should == '/dogs/and/cats/summer-pictures'
        end
      end
      
      context "A post having special characters in the title" do  
        it "should omit those characters." do
          post = {"id" => "my-blog-post.md", "date" => "2012-01-02", "title" => "=) My Blog Post!", 'permalink' => '/:title' }
          permalink = Ruhoh::Parsers::Posts.permalink(post)
          permalink.should_not == '/=)-my-blog-post-!'
          permalink.should == '/my-blog-post'
        end
      end
      
      context "A post having international characters in the title" do
        it "should omit those characters." do
          post = {"id" => "my-blog-post.md", "date" => "2012-01-02", "title" => "=) My Blog Post!", 'permalink' => '/:title' }
          post = {"id" => '안녕하세요-sérieux-è_é-三只熊.md', "date" => "2012-01-02", "title" => '안녕하세요-sérieux è_é-三只熊', 'permalink' => '/:title' }
          permalink = Ruhoh::Parsers::Posts.permalink(post)
          permalink.should == ('/'+CGI::escape('안녕하세요-sérieux-è_é-三只熊'))
        end
      end
    end
    
    describe "#to_title" do
      it "should prettify a filename slug for use as a title/header" do
        file_slug = 'my-post-title'
        title = Ruhoh::Parsers::Posts.to_title(file_slug)
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