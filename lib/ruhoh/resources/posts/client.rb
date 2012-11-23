module Ruhoh::Resources::Posts
  class Client
    Help = [
      {
        "command" => "draft <title>",
        "desc" => "Create a new draft. Post title is optional.",
      },
      {
        "command" => "new <title>",
        "desc" => "Create a new post. Post title is optional.",
      },
      {
        "command" => "titleize",
        "desc" => "Update draft filenames to their corresponding titles. Drafts without titles are ignored.",
      },
      {
        "command" => "drafts",
        "desc" => "List all drafts.",
      },
      {
        "command" => "list",
        "desc" => "List all posts.",
      }
    ]

    def initialize(ruhoh, data)
      @ruhoh = ruhoh
      @args = data[:args]
      @options = data[:options]
      @opt_parser = data[:opt_parser]
      @options.ext = (@options.ext || 'md').gsub('.', '')
      @iterator = 0
    end
    
  
    def draft
      self.draft_or_post(:draft)
    end

    def post
      self.draft_or_post(:post)
    end
  
    def draft_or_post(type)
      ruhoh = @ruhoh
      begin
        name = @args[1] || "untitled-#{type}"
        name = "#{name}-#{@iterator}" unless @iterator.zero?
        name = Ruhoh::Utils.to_slug(name)
        filename = File.join(@ruhoh.paths.posts, "#{name}.#{@options.ext}")
        @iterator += 1
      end while File.exist?(filename)
    
      FileUtils.mkdir_p File.dirname(filename)
      output = @ruhoh.db.scaffolds["#{type}.html"].to_s
      output = output.gsub('{{DATE}}', Ruhoh::Resources::Posts.formatted_date(Time.now))
      File.open(filename, 'w:UTF-8') {|f| f.puts output }
    
      Ruhoh::Friend.say { 
        green "New #{type}:" 
        green ruhoh.relative_path(filename)
        green 'View drafts at the URL: /dash'
      }
    end

    # Public: Update draft filenames to their corresponding titles.
    def titleize
      @ruhoh.db.posts['drafts'].each do |file|
        next unless File.basename(file) =~ /^untitled/
        parsed_page = Ruhoh::Utils.parse_page_file(file)
        next unless parsed_page['data']['title']
        new_name = Ruhoh::Utils.to_slug(parsed_page['data']['title'])
        new_file = File.join(File.dirname(file), "#{new_name}#{File.extname(file)}")
        FileUtils.mv(file, new_file)
        Ruhoh::Friend.say { green "Renamed #{file} to: #{new_file}" }
      end
    end
    
    # List pages
    def list
      data = @ruhoh.db.posts

      if @options.verbose
        Ruhoh::Friend.say {
          data.each_value do |p|
            cyan("- #{p['id']}")
            plain("  title: #{p['title']}") 
            plain("  url: #{p['url']}")
          end
        }
      else
        Ruhoh::Friend.say {
          data.each_value do |p|
            cyan("- #{p['id']}")
          end
        }
      end
    end
    
  end
  
end