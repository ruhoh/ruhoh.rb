class Ruhoh
  class Config
    include Observable

    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def [](key)
      touch unless @config
      @config[key]
    end

    def []=(key, value)
      touch unless @config
      @config[key] = value
    end

    def touch
      @config = @ruhoh.cascade.merge_data_file('config') || {}
      @config = @config.merge(collections_config)
      @config = @config.merge(find_theme_path(@config))

      defaults

      changed
      notify_observers(@config)

      self
    end

    def defaults
      self['compiled'] = self['compiled'] ? File.expand_path(self['compiled']) : "compiled"

      self['_root'] ||= {}
      self['_root']['permalink'] ||= "/:relative_path/:filename"
      self['_root']['paginator'] ||= {}
      self['_root']['paginator']['url'] ||= "/index/"
      self['_root']['rss'] ||= {}
      self['_root']['rss']['url'] ||= "/"

      self['base_path'] = self['base_path'].to_s.strip
      if self['base_path'].empty?
        self['base_path'] = '/'
      else
        self['base_path'] += "/" unless self['base_path'][-1] == '/'
      end

      Time.default_format = self['date_format'] || "%Y-%m-%d"
    end

    def base_path
      return '/' unless (@ruhoh.env == 'production')

      string = self['base_path'].chomp('/').reverse.chomp('/').reverse
      return '/' if string.empty? || string == '/'
      "/#{ string }/"
    end

    def find_theme_path(data)
      theme_name = data.find { |resource, data| data.is_a?(Hash) && data['use'] == "theme" }
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

            data.merge!(Ruhoh::Parse.data_file(File.realpath(id)) || {})
          }
        }
      end

      data
    end

    def to_hash
      @config.dup
    end
  end
end
