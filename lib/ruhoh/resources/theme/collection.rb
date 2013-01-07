module Ruhoh::Resources::Theme
  class Collection < Ruhoh::Resources::Base::Collection
    
    def config
      hash = super
      if hash['name'].empty?
        Ruhoh.log.error("Theme not specified in config.yml")
        return false
      end
      
      config_path = File.join(@ruhoh.base, "themes", hash["name"], "theme.yml")
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
    
    def path
      "themes/#{config["name"]}"
    end
    
    # noop
    def generate
      {}
    end
  end
end