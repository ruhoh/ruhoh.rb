class Ruhoh
  class Cascade

    attr_reader :config
    attr_accessor :theme, :base, :system

    def initialize(config)
      @config = config
      config.add_observer(self)
    end

    # Find a file in the base cascade directories
    # @return[Hash, nil] a single file pointer
    def find_file(key)
      dict = _all_files
      dict[key] || dict.values.find{ |a| key == a['id'].gsub(/.[^.]+$/, '') }
    end

    def merge_data_file(key)
      realpaths = []
      paths.map{ |a| a['path'] }.each do |path|
        FileUtils.cd(path) { 
          match = Dir["*"].find { |id|
            File.exist?(id) &&
              FileTest.file?(id) &&
                id.gsub(/.[^.]+$/, '') == key
          }
          next unless match
          realpaths << File.realpath(match)
        }
      end

      return nil unless realpaths && !realpaths.empty?

      data = {}
      realpaths.each do |path|
        data = Ruhoh::Utils.deep_merge(data, (Ruhoh::Parse.data_file(path) || {}))
      end

      data
    end

    # Collect all files from the base cascade directories.
    # @return[Hash] dictionary of file pointers
    def _all_files
      dict = {}
      paths.map{ |a| a['path'] }.each do |path|
        FileUtils.cd(path) { 
          Dir["*"].each { |id|
            next unless File.exist?(id) && FileTest.file?(id)
            dict[id] = {
              "id" => id,
              "realpath" => File.realpath(id),
            }
          }
        }
      end

      dict
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
