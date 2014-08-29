module Ruhoh::Collections::Data
  class CollectionView < SimpleDelegator
    include Ruhoh::Collectable

    def initialize(data, ruhoh=nil)
      _data = {}
      data.each { |item| _data[item.shortname] = item.data }
      super(_data)
    end


    private 

    # LEGACY 
    # ---------------------
    def dictionary
      resource_name == "data" ?
        _support_legacy_api :
        _support_new_data_api
    end

    def _support_new_data_api
      data = {}
      files.values.each do |item|
        name = File.basename(item.id, File.extname(item.id)) 
        data[name] = Silly::Parse.data_file(item.realpath) || {}
      end

      data
    end

    # TODO: This is ugly but it works. 
    # Should handle data extensions in the cascade more elegantly
    def _support_legacy_api
      found_paths = []

      @ruhoh.cascade.paths.each do |h|
        path_prefix = File.join(h["path"], resource_name)

        ["#{ path_prefix }.json", "#{ path_prefix }.yml", "#{ path_prefix }.yaml"].each do |file|
          found_paths << path_prefix and break if File.exist?(file)
        end
      end

      data = {}
      found_paths.each { |path| data.merge!(Silly::Parse.data_file(path) || {}) }

      data
    end
  end
end
