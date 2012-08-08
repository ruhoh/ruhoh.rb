class Ruhoh
  module Parsers
    module ThemeConfig
      
      def self.generate
        config = Ruhoh::Utils.parse_yaml_file(Ruhoh.paths.theme_config_data)
        if config.nil?
          Ruhoh::Friend.say{ 
            yellow "WARNING: theme.yml config file not found:"
            yellow "  #{Ruhoh.paths.theme_config_data}"
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
      
    end #ThemeConfig
  end #Parsers
end #Ruhoh