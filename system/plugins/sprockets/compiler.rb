require 'sprockets'

module Ruhoh::Collections::Asset
  class Compiler
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def run(collection_name)
      pages = @ruhoh.collections.load(collection_name)

      Ruhoh::Friend.say {
        cyan "#{collection_name.capitalize}: (#{ pages.count } #{ collection_name }) : (using sprockets)"
      }

      env = Sprockets::Environment.new
      #env.css_compressor = :sass
      env.logger = Logger.new(STDOUT)
      env.logger.level = Logger::WARN

      @ruhoh.query.paths.to_a.reverse.each do |path|
        env.append_path(path)
      end

      manifest = Sprockets::Manifest.new(env, @ruhoh.compiled_path("assets"))
      assets = pages.map{ |item|
        Ruhoh::Friend.say { green "  > #{ item.id }" }
        item.id
      }
      manifest.compile(assets)

      # Update the paths to the digest format:
      pages._cache.merge!(manifest.assets)
    end
  end
end
