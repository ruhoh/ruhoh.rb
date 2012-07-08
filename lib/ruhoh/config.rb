class Ruhoh
  # Structured container for global configuration parameters.
  module Config
    Config = Struct.new(
      :env,
      :pages_exclude,
      :pages_permalink,
      :pages_layout,
      :posts_exclude,
      :posts_layout,
      :posts_permalink,
      :rss_limit,
      :theme
    )

    def self.generate(path_to_config)
      site_config = Ruhoh::Utils.parse_yaml_file(path_to_config)
      unless site_config
        Ruhoh.log.error("Empty site_config.\nEnsure ./#{Ruhoh.names.config_data} exists and contains valid YAML")
        return false
      end

      theme = site_config['theme'] ? site_config['theme'].to_s.gsub(/\s/, '') : ''
      if theme.empty?
        Ruhoh.log.error("Theme not specified in #{Ruhoh.names.config_data}")
        return false
      end
      
      config = Config.new
      config.theme = theme
      config.env = site_config['env'] || nil

      config.rss_limit = site_config['rss']['limit'] rescue nil
      config.rss_limit = 20 if config.rss_limit.nil?

      config.posts_permalink = site_config['posts']['permalink'] rescue nil
      config.posts_layout = site_config['posts']['layout'] rescue nil
      config.posts_layout = 'post' if config.posts_layout.nil?
      excluded_posts = site_config['posts']['exclude'] rescue nil
      config.posts_exclude = Array(excluded_posts)
      config.posts_exclude = config.posts_exclude.map {|node| Regexp.new(node) }
      
      config.pages_permalink = site_config['pages']['permalink'] rescue nil
      config.pages_layout = site_config['pages']['layout'] rescue nil
      config.pages_layout = 'page' if config.pages_layout.nil?
      excluded_pages = site_config['pages']['exclude'] rescue nil
      config.pages_exclude = Array(excluded_pages)
      config.pages_exclude = config.pages_exclude.map {|node| Regexp.new(node) }
      
      config
    end
  end #Config
end #Ruhoh