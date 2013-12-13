module Ruhoh::Resources::Data
  class Collection
    include Ruhoh::Base::Collectable

    def glob
      "*"
    end

    def dictionary
      resource_name == "data" ?
        _support_legacy_api :
        _support_new_data_api
    end

    private 

    def _support_new_data_api
      data = {}
      files.values.each do |pointer|
        name = File.basename(pointer["id"], File.extname(pointer["id"])) 
        data[name] = Ruhoh::Parse.data_file(pointer["realpath"]) || {}
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
      found_paths.each { |path| data.merge!(Ruhoh::Parse.data_file(path) || {}) }

      data
    end
  end
end
