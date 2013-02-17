module Ruhoh::Base::Page
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
      draft_or_post(:draft)
    end

    def new
      draft_or_post(:post)
    end
  
    def draft_or_post(type)
      ruhoh = @ruhoh
      begin
        file = @args[2] || "untitled-#{type}"
        ext = File.extname(file).to_s
        name = File.basename(file, ext)
        name = "#{name}-#{@iterator}" unless @iterator.zero?
        name = Ruhoh::Utils.to_slug(name)
        ext  = ext.empty? ? @collection.config["ext"] : ext
        filename = File.join(@ruhoh.paths.base, @collection.resource_name, "#{name}#{ext}")
        @iterator += 1
      end while File.exist?(filename)
    
      FileUtils.mkdir_p File.dirname(filename)
      output = @ruhoh.db.scaffolds["#{type}.html"].to_s
      output = output.gsub('{{DATE}}', Time.now.strftime('%Y-%m-%d'))
      File.open(filename, 'w:UTF-8') {|f| f.puts output }
    
      resource_name = @collection.resource_name
      Ruhoh::Friend.say { 
        green "New #{type}:" 
        green ruhoh.relative_path(filename)
        green "View drafts/#{resource_name} at the URL: /dash"
      }
    end

    # Public: Update draft filenames to their corresponding titles.
    def titleize
      _drafts.values.each do |data|
        next unless File.basename(data['id']) =~ /^untitled/
        new_name = Ruhoh::Utils.to_slug(data['title'])
        new_file = "#{new_name}#{File.extname(data['id'])}"
        next if data['id'] == new_file
        FileUtils.cd(File.dirname(data['pointer']['realpath'])) {
          FileUtils.mv(data['id'], new_file)
        }
        Ruhoh::Friend.say { green "Renamed #{data['id']} to: #{new_file}" }
      end
    end
    
    def drafts
      _list(_drafts)
    end
    
    def _drafts
      @ruhoh.resources.load_collection_view(@collection.resource_name).drafts
    end
    
    def list
      data = @ruhoh.resources.load_collection_view(@collection.resource_name).all
      _list(data)
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