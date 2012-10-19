module Ruhoh::Plugins
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
      hash = super
      hash['name'] = hash['name'].to_s.strip
      if hash['name'].empty?
        Ruhoh.log.error("Theme not specified in #{Ruhoh.names.config_data}")
        return false
      end
      hash['path'] = File.join(@ruhoh.base, "themes", hash['name'])
      hash['path_javascripts'] =  File.join(hash['path'], Ruhoh.names.javascripts)
      hash['path_widgets'] =  File.join(hash['path'], Ruhoh.names.widgets)
      
      config_path = File.join(hash['path'], "theme.yml")
      config = Ruhoh::Utils.parse_yaml_file(config_path)
      if config.nil?
        Ruhoh::Friend.say{ 
          yellow "WARNING: theme.yml config file not found:"
          yellow "  #{config_path}"
        }
        return hash
      end
      return hash unless config.is_a? Hash
      config["exclude"] = Array(config['exclude']).compact.map do |node| 
        is_last = node[0] == "*"
        node = node.chomp("*").reverse.chomp("*").reverse
        node = Regexp.escape("#{node}")
        node = is_last ? "#{node}$" : "^#{node}"
        
        Regexp.new(node, true)
      end
      
      hash.merge(config)
    end
    
    def url_endpoint
      "/assets/#{config['name']}"
    end
    
    # noop
    def generate
      {}
    end

 end
end