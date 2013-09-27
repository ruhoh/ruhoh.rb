module Ruhoh::Resources::Data
  class Collection
    include Ruhoh::Base::Collectable

    # TODO: This is ugly but it works. 
    # Should handle data extensions in the cascade more elegantly
    def dictionary
      found_path_prefix = nil

      @ruhoh.cascade.paths.reverse.map do |h|
        path_prefix = File.join(h["path"], resource_name)

        ["#{ path_prefix }.json", "#{ path_prefix }.yml", "#{ path_prefix }.yaml"].each do |file|
          found_path_prefix = path_prefix and break if File.exist?(file)
        end

        break if found_path_prefix
      end

      return {} unless found_path_prefix

      Ruhoh::Parse.data_file(found_path_prefix) || {}
    end
  end
end