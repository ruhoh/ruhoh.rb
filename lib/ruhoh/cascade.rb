class Ruhoh
  class Cascade

    attr_reader :config
    attr_accessor :theme, :base, :system

    def initialize(config)
      @config = config
      config.add_observer(self)
    end

    # When config is updated
    def update(config_data)
      if config_data['_theme_collection']
        @theme = File.join(base, config_data['_theme_collection']) 
      end
    end

    # Default paths to the 3 levels of the cascade.
    def paths
      a = [
        {
          "name" => "system",
          "path" => system
        },
        {
          "name" => "base",
          "path" => base
        }
      ]
      a << {
        "name" => "theme",
        "path" => theme
      } if theme

      a
    end

    def system
      File.join(Ruhoh::Root, "system")
    end
  end
end
