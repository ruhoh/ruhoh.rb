require 'ruhoh/compiler'

class Ruhoh
  class Client
    
    Paths = Struct.new(:page_template, :post_template, :layout_template, :theme_template)
    BlogScaffold = 'git://github.com/ruhoh/blog.git'
    
    def initialize(data)
      @iterator = 0
      self.setup_paths
      self.setup_options(data)
      
      cmd = (data[:args][0] == 'new') ? 'blog' : (data[:args][0] || 'help')
      Ruhoh::Friend.say { 
        red "Command not found"
        exit 
      } unless self.respond_to?(cmd)

      Ruhoh.setup unless ['help','blog'].include?(cmd)

      self.__send__(cmd)
    end  
    
    def setup_options(data)
      @args = data[:args]
      @options = data[:options]
      @opt_parser = data[:opt_parser]
      @options.ext = (@options.ext || 'md').gsub('.', '')
    end
    
    def setup_paths
      @paths = Paths.new
      @paths.page_template    = File.join(Ruhoh::Root, "scaffolds", "page.html")
      @paths.post_template    = File.join(Ruhoh::Root, "scaffolds", "post.html")
      @paths.layout_template  = File.join(Ruhoh::Root, "scaffolds", "layout.html")
      @paths.theme_template   = File.join(Ruhoh::Root, "scaffolds", "theme")
    end

    # Internal: Show Client Utility help documentation.
    def help
      file = File.join(Ruhoh::Root, 'lib', 'ruhoh', 'client', 'help.yml')
      content = Ruhoh::Utils.parse_file_as_yaml(file)
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
    
    # Public: Create a new draft file.
    # Requires no settings as it is meant to be fastest way to create content.
    def draft
      begin
        filename = File.join(Ruhoh.paths.posts, "untitled-#{@iterator}.#{@options.ext}")
        @iterator += 1
      end while File.exist?(filename)
      
      FileUtils.mkdir_p File.dirname(filename)

      output = File.open(@paths.post_template) { |f| f.read }
      output = output.gsub('{{DATE}}', Ruhoh::Parsers::Posts.formatted_date(Time.now))
      File.open(filename, 'w') {|f| f.puts output }
      
      Ruhoh::Friend.say { 
        green "New draft:" 
        green Ruhoh.relative_path(filename)
        green 'View drafts at the URL: /dash'
      }
    end
    alias_method :post, :draft
    
    # Public: Create a new page file.
    def page
      name = @args[1]
      Ruhoh::Friend.say { 
        red "Please specify a path"
        plain "  ex: ruhoh page projects/hello-world"
        exit
      } if (name.nil? || name.gsub(/\s/, '').empty?)

      filename = File.join(Ruhoh.paths.pages, name.gsub(/\s/, '-'))
      filename = File.join(filename, "index.#{@options.ext}") if File.extname(filename) == ""
      if File.exist?(filename)
        abort("Create new page: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end

      FileUtils.mkdir_p File.dirname(filename)
      File.open(@paths.page_template) do |template|
        File.open(filename, 'w') do |page|
          page.puts template.read
        end
      end
      
      Ruhoh::Friend.say { 
        green "New page:"
        plain Ruhoh.relative_path(filename)
      }
    end

    # Public: Update draft filenames to their corresponding titles.
    def titleize
       Ruhoh::Parsers::Posts.files.each do |file|
          next unless File.basename(file) =~ /^untitled/
          parsed_page = Ruhoh::Utils.parse_file(file)
          next unless parsed_page['data']['title']
          new_name = Ruhoh::Parsers::Posts.to_slug(parsed_page['data']['title'])
          new_file = File.join(File.dirname(file), "#{new_name}#{File.extname(file)}")
          FileUtils.mv(file, new_file)
          Ruhoh::Friend.say { green "Renamed #{file} to: #{new_file}" }
       end
    end
    
    # Public: Compile to static website.
    def compile
      Ruhoh::Compiler.new(@args[1]).compile
    end
    
    # Public: Create a new blog at the directory provided.
    def blog
      name = @args[1]
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
        cyan "  git clone #{BlogScaffold} #{target_directory}"

        if system('git', 'clone', BlogScaffold, target_directory)
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
    
    # Public: Create a new theme scaffold with the given name.
    def theme
      name = @args[1]
      Ruhoh::Friend.say { 
        red "Please specify a theme name." 
        cyan "ex: ruhoh new theme the-rain"
        exit
      } if name.nil?

      target_directory = File.expand_path(File.join(Ruhoh.paths.theme, '..', name.gsub(/\s/, '-').downcase))
      
      if File.exist?(target_directory)
        abort("Create new theme: \e[31mAborted!\e[0m") if ask("#{target_directory} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end

      FileUtils.mkdir target_directory unless File.exist?(target_directory)
      FileUtils.cp_r "#{@paths.theme_template}/.", target_directory
      
      Ruhoh::Friend.say { 
        green "New theme scaffold:"
        green target_directory
      }
    end

    # Public: Create a new layout file for the active theme.
    def layout
      name = @args[1]
      Ruhoh::Friend.say { 
        red "Please specify a layout name." 
        cyan "ex: ruhoh new layout splash"
        exit
      } if name.nil?
      
      filename = File.join(Ruhoh.paths.layouts, name.gsub(/\s/, '-').downcase) + ".html"
      if File.exist?(filename)
        abort("Create new layout: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end
      
      FileUtils.mkdir_p File.dirname(filename)
      File.open(@paths.layout_template) do |template|
        File.open(filename, 'w') do |page|
          page.puts template.read
        end
      end
      
      Ruhoh::Friend.say {
        green "New layout:"
        plain Ruhoh.relative_path(filename)
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
      require 'pp'
      Ruhoh::DB.update_all
      Ruhoh::Friend.say {
        plain Ruhoh::Templaters::Base.build_payload.pretty_inspect
      }
    end
    
    # Internal: Outputs a list of the given data-type to the terminal.
    def list(type)
      data = case type
      when :posts
        Ruhoh::DB.update(:posts)
        Ruhoh::DB.posts['dictionary']
      when :drafts
        Ruhoh::DB.update(:posts)
        drafts = Ruhoh::DB.posts['drafts']
        h = {}
        drafts.each {|id| h[id] = Ruhoh::DB.posts['dictionary'][id]}
        h
      when :pages
        Ruhoh::DB.update(:pages)
        Ruhoh::DB.pages
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