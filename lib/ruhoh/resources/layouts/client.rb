module Ruhoh::Resources::Layouts
  class Client
    Help = [
      {
        "command" => "new <name>",
        "desc" => "Create a new layout for the currently active theme."
      }
    ]      

    def initialize(collection, data)
      @ruhoh = collection.ruhoh
      @collection = collection
      @args = data[:args]
      @options = data[:options]
    end
    
    # Public: Create a new layout file for the active theme.
    def new
      ruhoh = @ruhoh
      name = @args[2]
      Ruhoh::Friend.say { 
        red "Please specify a layout name." 
        cyan "ex: ruhoh layouts new splash"
        exit
      } if name.nil?

      filename = File.join((@ruhoh.cascade.theme || @ruhoh.cascade.base), "layouts", name.gsub(/\s/, '-').downcase) + ".html"

      if File.exist?(filename)
        abort("Create new layout: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end

      FileUtils.mkdir_p File.dirname(filename)

      File.open(filename, 'w:UTF-8') do |page|
        page.puts (@collection.scaffold || '')
      end

      Ruhoh::Friend.say {
        green "New layout:"
        plain ruhoh.relative_path(filename)
      }
    end
  end
end