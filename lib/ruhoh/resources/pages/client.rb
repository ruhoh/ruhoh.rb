module Ruhoh::Resources::Pages
  class Client
    Help = [
      {
        "command" => "draft <title>",
        "desc" => "Create a new draft. Title is optional.",
      },
      {
        "command" => "new <title>",
        "desc" => "Create a new resource. Title is optional.",
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
        "desc" => "List all resources.",
      }
    ]

    def initialize(collection, data)
      @ruhoh = collection.ruhoh
      @collection = collection
      @args = data[:args]
      @options = data[:options]
      @iterator = 0
    end

    def draft
      create(draft: true)
    end

    def new
      create
    end

    # Public: Update draft filenames to their corresponding titles.
    def titleize
      @collection.dictionary.each do |id, data|
        next unless File.basename(data['id']) =~ /^untitled/
        new_name = Ruhoh::Utils.to_slug(data['title'])
        new_file = "#{new_name}#{File.extname(data['id'])}"
        old_file = File.basename(data['id'])
        next if old_file == new_file

        FileUtils.cd(File.dirname(data['pointer']['realpath'])) {
          FileUtils.mv(old_file, new_file)
        }
        Ruhoh::Friend.say { green "Renamed #{old_file} to: #{new_file}" }
      end
    end

    def drafts
      _list(@collection.drafts)
    end

    def list
      _list(@collection.all)
    end

    protected

    def create(opts={})
      ruhoh = @ruhoh

      begin
        file = @args[2] || "untitled"
        ext = File.extname(file).to_s
        ext  = ext.empty? ? @collection.config["ext"] : ext

        # filepath vs title
        name =  if file.include?('/')
                  name = File.basename(file, ext).gsub(/\s+/, '-')
                  File.join(File.dirname(file), name)
                else
                  Ruhoh::Utils.to_slug(File.basename(file, ext))
                end

        name = "#{name}-#{@iterator}" unless @iterator.zero?
        filename = opts[:draft] ?
          File.join(@ruhoh.paths.base, @collection.resource_name, "drafts", "#{name}#{ext}") :
          File.join(@ruhoh.paths.base, @collection.resource_name, "#{name}#{ext}")
        @iterator += 1
      end while File.exist?(filename)

      FileUtils.mkdir_p File.dirname(filename)
      output = (@collection.scaffold || '').gsub('{{DATE}}', Time.now.strftime('%Y-%m-%d'))

      File.open(filename, 'w:UTF-8') {|f| f.puts output }

      resource_name = @collection.resource_name
      Ruhoh::Friend.say { 
        green "New #{resource_name}:"
        green "  > #{ruhoh.relative_path(filename)}"
        if opts[:draft]
          plain "View drafts at the URL: /dash"
        end
      }
    end

    def _list(data)
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
          data.each do |p|
            cyan("- #{p['id']}")
          end
        }
      end
    end
  end
end