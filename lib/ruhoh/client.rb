require 'benchmark'

require 'ruhoh/programs/compile'
require 'ruhoh/console_methods'

module Ruhoh::Publish; end
Dir[File.join(File.dirname(__FILE__), 'publish', '*.rb')].each { |f|
  require f
}

class Ruhoh

  class Client
    DefaultBlogScaffold = 'git://github.com/ruhoh/blog.git'
    Help = [
      {
        "command" => "new <directory_path>",
        "desc" => "Create a new blog directory based on the Ruhoh specification."
      },
      {
        "command" => "compile",
        "desc" => "Compile to static website."
      },
      {
        "command" => "publish <service>",
        "desc" => "Publish site using a given service library"
      },
      {
        "command" => "help",
        "desc" => "Show this menu."
      }
    ]
    def initialize(data)
      @args = data[:args]
      @options = data[:options]
      @opt_parser = data[:opt_parser]

      cmd = (@args[0] == 'new') ? 'blog' : (@args[0] || 'help')

      return server if %w(s serve server).include?(cmd)

      @ruhoh = Ruhoh.new
      @ruhoh.setup_plugins

      return __send__(cmd) if respond_to?(cmd)

      Ruhoh::Friend.say {
        yellow "-> Autoloading '#{cmd}' as pages collection"
      } unless @ruhoh.collections.exists?(cmd)

      collection = @ruhoh.collection(cmd)
      client = collection.load_client(data)

      Ruhoh::Friend.say { 
        red "method '#{data[:args][1]}' not found for #{client.class}"
        exit 
      } unless @args[1] && client.respond_to?(@args[1])

      client.__send__(@args[1])
    end

    # Thanks rails! https://github.com/rails/rails/blob/master/railties/lib/rails/commands/console.rb
    def console
      require 'irb'
      require 'pp'
      Ruhoh::ConsoleMethods.env = @args[1]
      IRB::ExtendCommandBundle.send :include, Ruhoh::ConsoleMethods

      ARGV.clear # IRB throws an error otherwise.
      IRB.start
    end
    alias_method :c, :console

    # Show Client Utility help documentation.
    def help
      options = @opt_parser.help
      resources = [{"methods" => Help}]
      resources += @ruhoh.collections.all.map {|name|
        collection = @ruhoh.collection(name)
        next unless collection.client?
        next unless collection.client.const_defined?(:Help)
        {
          "name" => name,
          "methods" => collection.client.const_get(:Help)
        }
      }.compact

      Ruhoh::Friend.say { 
        plain "Ruhoh is a nifty, modular static blog generator."
        plain "It is the Universal Static Blog API."
        plain "Visit http://www.ruhoh.com for complete usage and documentation."
        plain ''
        plain options
        plain ''
        plain 'Commands:'
        plain ''
        resources.each do |resource|
          resource["methods"].each do |method|
            if resource["name"]
              green("  " + "#{resource["name"]} #{method["command"]}")
            else
              green("  " + method["command"])
            end
            plain("    "+ method["desc"])
          end
        end
      }
    end

    # Public: Compile to static website.
    def compile
      puts Benchmark.measure {
        Ruhoh::Program.compile(@args[1])
      }
    end

    def server
      require 'rack'
      Rack::Server.start({ 
        app: Ruhoh::Program.preview,
        Port: (@args[1] || 9292)
      })
    end
    alias_method :s, :server
    alias_method :serve, :server

    def publish
      service = @args[1].to_s.downcase.capitalize
      if service.empty?
        Ruhoh::Friend.say {
          red "Specify a publishing service"
          exit
        }
      end

      if Ruhoh::Publish.const_defined?(service.to_sym)
        publish_config = Ruhoh::Parse.data_file(@ruhoh.cascade.base, "publish") || {}
        Ruhoh::Publish.const_get(service.to_sym).new.run(@args, publish_config[service.downcase])
      else
        Ruhoh::Friend.say {
          red "'#{ service }' not found."
          plain "Ensure the service class is properly namespaced at Ruhoh::Publish::#{ service }"
          exit
        }
      end
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
end