require 'ruhoh/compiler'
require 'ruhoh/client/console_methods'
require 'irb'

class Ruhoh
  
  class Client
    
    Paths = Struct.new(:page_template, :draft_template, :post_template, :layout_template, :theme_template)
    DefaultBlogScaffold = 'git://github.com/ruhoh/blog.git'
    
    def initialize(data)
      @iterator = 0
      self.setup_options(data)
      
      cmd = (data[:args][0] == 'new') ? 'blog' : (data[:args][0] || 'help')
      Ruhoh::Friend.say { 
        red "Command not found"
        exit 
      } unless self.respond_to?(cmd)

      unless ['help','console','blog','compile'].include?(cmd)
        @ruhoh = Ruhoh.new
        @ruhoh.setup
        @ruhoh.setup_paths
        @ruhoh.setup_urls
      end  

      self.__send__(cmd)
    end  
    
    # Thanks rails! https://github.com/rails/rails/blob/master/railties/lib/rails/commands/console.rb
    def console
      ARGV.clear # IRB throws an error otherwise.
      require 'pp'
      IRB::ExtendCommandBundle.send :include, Ruhoh::ConsoleMethods
      IRB.start
    end
    
    def setup_options(data)
      @args = data[:args]
      @options = data[:options]
      @opt_parser = data[:opt_parser]
      @options.ext = (@options.ext || 'md').gsub('.', '')
    end
    
    # Internal: Show Client Utility help documentation.
    def help
      file = File.join(Ruhoh::Root, 'lib', 'ruhoh', 'client', 'help.yml')
      content = Ruhoh::Utils.parse_yaml_file(file)
      options = @opt_parser.help
      Ruhoh::Friend.say { 
        plain content['description']
        plain ''
        plain options
        plain ''
        plain 'Commands:'
        plain ''
        content['commands'].each do |a|
          green("  " + a["command"])
          plain("    "+ a["desc"])
        end
      }
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
        name = Ruhoh::Urls.to_slug(name)
        filename = File.join(@ruhoh.paths.posts, "#{name}.#{@options.ext}")
        @iterator += 1
      end while File.exist?(filename)
      
      @ruhoh.db.update(:scaffolds)

      FileUtils.mkdir_p File.dirname(filename)
      output = @ruhoh.db.scaffolds["#{type}.html"].to_s
      output = output.gsub('{{DATE}}', Ruhoh::Parsers::Posts.formatted_date(Time.now))
      File.open(filename, 'w:UTF-8') {|f| f.puts output }
      
      Ruhoh::Friend.say { 
        green "New #{type}:" 
        green ruhoh.relative_path(filename)
        green 'View drafts at the URL: /dash'
      }
    end
    
    # Public: Create a new page file.
    def page
      ruhoh = @ruhoh
      name = @args[1]
      Ruhoh::Friend.say { 
        red "Please specify a path"
        plain "  ex: ruhoh page projects/hello-world"
        exit
      } if (name.nil? || name.gsub(/\s/, '').empty?)

      filename = File.join(@ruhoh.paths.pages, name.gsub(/\s/, '-'))
      filename = File.join(filename, "index.#{@options.ext}") if File.extname(filename) == ""
      if File.exist?(filename)
        abort("Create new page: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end
      
      @ruhoh.db.update(:scaffolds)
      
      FileUtils.mkdir_p File.dirname(filename)
      File.open(filename, 'w:UTF-8') do |page|
        page.puts @ruhoh.db.scaffolds['page.html'].to_s
      end
      
      Ruhoh::Friend.say { 
        green "New page:"
        plain ruhoh.relative_path(filename)
      }
    end

    # Public: Update draft filenames to their corresponding titles.
    def titleize
      @ruhoh.db.update(:posts)
      @ruhoh.db.posts['drafts'].each do |file|
        next unless File.basename(file) =~ /^untitled/
        parsed_page = Ruhoh::Utils.parse_page_file(file)
        next unless parsed_page['data']['title']
        new_name = Ruhoh::Urls.to_slug(parsed_page['data']['title'])
        new_file = File.join(File.dirname(file), "#{new_name}#{File.extname(file)}")
        FileUtils.mv(file, new_file)
        Ruhoh::Friend.say { green "Renamed #{file} to: #{new_file}" }
      end
    end
    
    # Public: Compile to static website.
    def compile
      Ruhoh::Program.compile(@args[1])
    end
    
    # Public: Create a new blog at the directory provided.
    def blog
      name = @args[1]
      scaffold = @args.length > 2 ? @args[2] : DefaultBlogScaffold
      useHg = @options.hg
      Ruhoh::Friend.say { 
        red "Please specify a directory path." 
        plain "  ex: ruhoh new the-blogist"
        exit
      } if name.nil?

      target_directory = File.join(Dir.pwd, name)

      Ruhoh::Friend.say { 
        red "#{target_directory} already exists."
        plain "  Specify another directory or `rm -rf` this directory first."
        exit
      } if File.exist?(target_directory)
      
      Ruhoh::Friend.say { 
        plain "Trying this command:"

        if useHg
          cyan "  hg clone #{scaffold} #{target_directory}"
          success = system('hg', 'clone', scaffold, target_directory)
        else
          cyan "  git clone #{scaffold} #{target_directory}"
          success = system('git', 'clone', scaffold, target_directory)
        end

        if success
          green "Success! Now do..."
          cyan "  cd #{target_directory}"
          cyan "  rackup -p9292"
          cyan "  http://localhost:9292"
        else
          red "Could not git clone blog scaffold. Please try it manually:"
          cyan "  git clone git://github.com/ruhoh/blog.git #{target_directory}"
        end
      }
    end
    
    # Public: Create a new layout file for the active theme.
    def layout
      ruhoh = @ruhoh
      name = @args[1]
      Ruhoh::Friend.say { 
        red "Please specify a layout name." 
        cyan "ex: ruhoh new layout splash"
        exit
      } if name.nil?
      
      filename = File.join(@ruhoh.paths.theme_layouts, name.gsub(/\s/, '-').downcase) + ".html"
      if File.exist?(filename)
        abort("Create new layout: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end
      
      @ruhoh.db.update(:scaffolds)
      
      FileUtils.mkdir_p File.dirname(filename)
      File.open(filename, 'w:UTF-8') do |page|
        page.puts @ruhoh.db.scaffolds['layout.html'].to_s
      end
      
      Ruhoh::Friend.say {
        green "New layout:"
        plain ruhoh.relative_path(filename)
      }
    end

    # Public : List drafts
    def drafts
      self.list(:drafts)
    end

    # Public : List posts
    def posts
      self.list(:posts)
    end

    # Public : List pages
    def pages
      self.list(:pages)
    end
 
    # Return the payload hash for inspection/study.
    def payload
      ruhoh = @ruhoh
      require 'pp'
      @ruhoh.db.update_all
      Ruhoh::Friend.say {
        plain ruhoh.db.payload.pretty_inspect
      }
    end
    
    # Internal: Outputs a list of the given data-type to the terminal.
    def list(type)
      data = case type
      when :posts
        @ruhoh.db.update(:posts)
        @ruhoh.db.posts['dictionary']
      when :drafts
        @ruhoh.db.update(:posts)
        drafts = @ruhoh.db.posts['drafts']
        h = {}
        drafts.each {|id| h[id] = @ruhoh.db.posts['dictionary'][id]}
        h
      when :pages
        @ruhoh.db.update(:pages)
        @ruhoh.db.pages
      end  

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
    
    # Internal: Get the last active file based on data-type.
    # Note File.ctime is the last time the file was changed as opposed to created.
    # Returns: String file id, where id is the relative path to the file.
    def last(type)
      self.get_files(type).sort_by { |f| File.ctime(f) }.last || nil
    end
    
    # Internal: Get an Array list of file ids based on the data-type.
    # Returns: Array of file ids (ids are relative paths to the file.)
    def get_files(type)
      case type
      when 'post'
        Ruhoh::Parsers::Posts.files
      when 'page'
        Ruhoh::Parsers::Pages.files
      else
        Ruhoh::Friend.say { red  "Type: '#{type}' not supported." }
        exit
      end
    end
    
    def ask(message, valid_options)
      if valid_options
        answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
      else
        answer = get_stdin(message)
      end
      answer
    end

    def get_stdin(message)
      print message
      STDIN.gets.chomp
    end
    
    
  end #Client
end #Ruhoh