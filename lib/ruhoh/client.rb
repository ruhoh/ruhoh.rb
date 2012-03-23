require 'ruhoh/compiler'

class Ruhoh
  
  class Client
    BlogTemplatePath = File.join(Ruhoh::Root, 'scaffolds/blog')
    PageTemplatePath = File.join(Ruhoh::Root, "scaffolds", "page.html")
    PostTemplatePath = File.join(Ruhoh::Root, "scaffolds", "post.html")
    LayoutTemplatePath = File.join(Ruhoh::Root, "scaffolds", "layout.html")
    ThemeTemplatePath = File.join(Ruhoh::Root, "scaffolds", "theme")
    
    def initialize(args)
      case args[0]
      when 'new'
        self.new_blog(args[1])
      when 'page'
        self.new_page(args[1])
      when 'post'
        self.new_post(args[1], args[2])
      when 'draft'
        self.new_post(args[1], args[2], 'draft')
      when 'layout'
        self.new_layout(args[1])
      when 'theme'
        self.new_theme(args[1])
      when 'compile'
        self.compile(args[1])
      else
        help = File.open(File.join(Ruhoh::Root, 'help'))
        puts help.read
        help.close
      end
    end  

    def new_post(title, date, type='post')
      title ||= "new-post"
      slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      begin
        date = (date ? Time.parse(date) : Time.now).strftime('%Y-%m-%d')
      rescue Exception => e
        puts "\e[31mERROR\e[0m - date format must be YYYY-MM-DD, please check you typed it correctly!"
        exit -1
      end
      filename = File.join(Ruhoh.paths["#{type}s"], "#{date}-#{slug}.md") #custom ext?
      if File.exist?(filename)
        abort("\e[31m Aborted! \e[0m") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end

      FileUtils.mkdir_p File.dirname(filename)
      File.open(PostTemplatePath) do |template|
        File.open(filename, 'w') do |post|
          post.puts template.read
        end
      end
      
      puts "\e[32mCreated new #{type}:\e[0m #{filename}"
    end
      
    def new_page(name)
      name ||= "new-page.md"
      filename = File.join(Ruhoh.paths.site_source, name.gsub(/\s/, '-'))
      filename = File.join(filename, "index.html") if File.extname(filename) == ""
      if File.exist?(filename)
        abort("Create new page: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end

      FileUtils.mkdir_p File.dirname(filename)
      File.open(PageTemplatePath) do |template|
        File.open(filename, 'w') do |page|
          page.puts template.read
        end
      end
      
      puts "\e[32mCreated new page:\e[0m #{filename}"
    end
    
    def new_blog(name)
      if name.nil?
        puts "Name must be specified"
        exit 0
      end

      target_directory = File.join(Dir.pwd, name)

      if File.exist?(target_directory)
        puts "#{target_directory} already exists. Specify another directory."
        exit 0
      end

      FileUtils.mkdir target_directory
      FileUtils.cp_r "#{BlogTemplatePath}/.", target_directory
      
      puts "=> Blog successfully cloned to:"
      puts "=> #{target_directory}"
    end
    
    def new_theme(name)
      if name.nil?
        puts "Name must be specified"
        exit 0
      end

      target_directory = File.expand_path(File.join(Ruhoh.paths.theme, '..', name.gsub(/\s/, '-').downcase))
      
      if File.exist?(target_directory)
        abort("Create new theme: \e[31mAborted!\e[0m") if ask("#{target_directory} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end

      FileUtils.mkdir target_directory unless File.exist?(target_directory)
      FileUtils.cp_r "#{ThemeTemplatePath}/.", target_directory
      
      puts "\e[32mCreated new theme scaffold:\e[0m #{target_directory}"
    end
    
    def new_layout(name)
      filename = File.join(Ruhoh.paths.layouts, name.gsub(/\s/, '-').downcase) + ".html"
      if File.exist?(filename)
        abort("Create new layout: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end
      
      FileUtils.mkdir_p File.dirname(filename)
      File.open(LayoutTemplatePath) do |template|
        File.open(filename, 'w') do |page|
          page.puts template.read
        end
      end
      
      puts "\e[32mCreated new layout:\e[0m #{filename}"
    end
    
    def compile(target_directory=nil)
      Ruhoh::Compiler.new(target_directory).compile
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
    
  end
  
end #Ruhoh