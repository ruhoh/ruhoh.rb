module Ruhoh::Plugins
  class Layouts < Plugin
    
    class Modeler < BaseModeler
      def generate
        dict = {}
        id = File.basename(@pointer['id'], File.extname(@pointer['id']))
        data = Ruhoh::Utils.parse_layout_file(@pointer['realpath'])
        data['id'] = id
        dict[id] = data
        dict
      end
    end

    class Client
      Help = [
        {
          "command" => "new <name>",
          "desc" => "Create a new layout for the currently active theme."
        }
      ]      

      def initialize(ruhoh, data)
        @ruhoh = ruhoh
        @args = data[:args]
        @options = data[:options]
        @opt_parser = data[:opt_parser]
        @options.ext = (@options.ext || 'md').gsub('.', '')
      end
      
      # Public: Create a new layout file for the active theme.
      def new
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
      
    end
    
  end
end