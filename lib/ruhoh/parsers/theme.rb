class Ruhoh
  module Parsers
    class Theme < Base
      
      # Need to have ability to set a specific theme and work
      # in the context of that theme implicitly
      Namespaces = [
        "javascripts",
        "layouts",
        "partials",
        "media",
        "stylesheets",
        "widgets",
        "theme.yml"
      ]
      
      def config
        # gets the name
        #hash = super
        #hash['name']
        hash = {}
        # now we can get the theme specific config.
        config = Ruhoh::Utils.parse_yaml_file(@ruhoh.paths.theme_config_data)
        if config.nil?
          Ruhoh::Friend.say{ 
            yellow "WARNING: theme.yml config file not found:"
            yellow "  #{@ruhoh.paths.theme_config_data}"
          }
          return {}
        end
        return {} unless config.is_a? Hash
        
        config["exclude"] = Array(config['exclude']).compact.map do |node| 
          is_last = node[0] == "*"
          node = node.chomp("*").reverse.chomp("*").reverse
          node = Regexp.escape("#{node}")
          node = is_last ? "#{node}$" : "^#{node}"
          
          Regexp.new(node, true)
        end
        
        config
      end
      
      # noop
      def generate
        {}
      end

      class Modeler < BaseModeler
        
      end
   end
  end
end