module Ruhoh::Resources::Pages
  class Client
    Help = [
      {
        "command" => "new <path>",
        "desc" => "Create a new page at the given path.",
      },
      {
        "command" => "list",
        "desc" => "List all pages.",
      }
    ]

    def initialize(ruhoh, data)
      @ruhoh = ruhoh
      @args = data[:args]
      @options = data[:options]
      @opt_parser = data[:opt_parser]
      @options.ext = (@options.ext || 'md').gsub('.', '')
    end
    
    def new
      ruhoh = @ruhoh
      name = @args[2]
      Ruhoh::Friend.say { 
        red "Please specify a path"
        plain "  ex: ruhoh pages new projects/hello-world"
        exit
      } if (name.nil? || name.gsub(/\s/, '').empty?)

      filename = File.join(@ruhoh.paths.base, "pages", name.gsub(/\s/, '-'))
      filename = File.join(filename, "index.#{@options.ext}") if File.extname(filename) == ""
      if File.exist?(filename)
        abort("Create new page: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end

      FileUtils.mkdir_p File.dirname(filename)
      File.open(filename, 'w:UTF-8') do |page|
        page.puts @ruhoh.db.scaffolds['page.html'].to_s
      end

      Ruhoh::Friend.say { 
        green "New page:"
        plain ruhoh.relative_path(filename)
      }
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