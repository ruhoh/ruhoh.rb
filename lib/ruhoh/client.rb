class Ruhoh
  
  class Client
    PageTemplatePath = File.join(Ruhoh::Root, "scaffolds", "page.html")
    PostTemplatePath = File.join(Ruhoh::Root, "scaffolds", "post.html")
    
    def initialize(args)
      case args[0]
      when 'new'
        self.new_blog(args[1])
      when 'page'
        self.new_page(args[1])
      when 'post'
        self.new_post(args[1], args[2])
      else
        help = File.open(File.join(Ruhoh::Root, "scaffolds", 'help'))
        puts help.read
        help.close
      end
    end  
    
    def new_post(title, date)
      title ||= "new-post"
      slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      begin
        date = (date ? Time.parse(date) : Time.now).strftime('%Y-%m-%d')
      rescue Exception => e
        puts "\e[31mERROR\e[0m - date format must be YYYY-MM-DD, please check you typed it correctly!"
        exit -1
      end
      filename = File.join(Ruhoh.paths.posts, "#{date}-#{slug}.md") #custom ext?
      if File.exist?(filename)
        abort("\e[31m Aborted! \e[0m") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end

      FileUtils.mkdir_p File.dirname(filename)
      File.open(PostTemplatePath) do |template|
        File.open(filename, 'w') do |post|
          post.puts template.read
        end
      end
      
      puts "\e[32mCreated new post:\e[0m #{filename}"
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

      source_directory = File.join(Ruhoh::Root, 'scaffolds/blog')
      target_directory = File.join(Dir.pwd, name)

      if File.exist?(target_directory)
        puts "#{target_directory} already exists. Specify another directory."
        exit 0
      end

      FileUtils.mkdir target_directory
      FileUtils.cp_r "#{source_directory}/.", target_directory
      
      puts "=> Blog successfully cloned to:"
      puts "=> #{target_directory}"
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