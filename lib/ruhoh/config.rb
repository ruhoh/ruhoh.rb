class Ruhoh
  class Config < SimpleDelegator
    include Observable

    def initialize(ruhoh)
      @ruhoh = ruhoh
      @data = {}
      super(@data)
    end

    # Regenerate the config data
    def touch
      data = @ruhoh.cascade.merge_data_file('config') || {}
      data = Ruhoh::Utils.deep_merge(data, collections_config)
      data = Ruhoh::Utils.deep_merge(data, find_theme_path)

      @data.clear
      @data.merge!(data)
      
      Time.default_format = @data['date_format']
      @data["compiled"] = File.expand_path(@data["compiled"])

      changed
      notify_observers(@data)

      self
    end

    def base_path
      return '/' unless (@ruhoh.env == 'production')

      @data['base_path'] += "/" unless @data['base_path'][-1] == '/'
      string = @data['base_path'].chomp('/').reverse.chomp('/').reverse
      return '/' if string.empty? || string == '/'
      "/#{ string }/"
    end

    private

    def find_theme_path
      theme_name = @data.find { |resource, data| data.is_a?(Hash) && data['use'] == "theme" }
      if theme_name
        Ruhoh::Friend.say { plain "Using theme: \"#{theme_name[0]}\""}
        { "_theme_collection" => theme_name[0] }
      else 
        { "_theme_collection" => nil }
      end
    end

    # Quick and dirty way to scan for config files in collection folders.
    # This is needed because we don't know which collection defines itself as a theme 
    # so we'll scan for any configs and merge the data to find the theme folder.
    def collections_config
      data = {}
      @ruhoh.cascade.paths.map{ |a| a['path'] }.each do |path|
        FileUtils.cd(path) { 
          Dir["*/config.*"].each { |id|
            next unless File.exist?(id) && FileTest.file?(id)
            data = Ruhoh::Utils.deep_merge(data, (Ruhoh::Parse.data_file(File.realpath(id)) || {}))
          }
        }
      end

      data
    end
  end
end
