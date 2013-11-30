require 'sprockets'

module Ruhoh::SprocketsPlugin
  module Compiler
    extend Ruhoh::Base::CompilableAsset
    def run
      env = Sprockets::Environment.new
      env.css_compressor = :sass
      env.logger = Logger.new(STDOUT)
      env.logger.level = Logger::WARN

      collection = @collection

      unless collection.paths?
        Ruhoh::Friend.say { yellow "#{collection.resource_name.capitalize}: directory not found - skipping." }
        return
      end

      Ruhoh::Friend.say { cyan "#{collection.resource_name.capitalize}: (using sprockets)" }

      collection.paths.reverse.each do |path|
        env.append_path(path)
      end

      compile_collection_path

      manifest = Sprockets::Manifest.new(env, @collection.compiled_path)
      assets = collection.files.values.map{ |p|
        Ruhoh::Friend.say { green "  > #{p['id']}" }
        p["id"]
      }
      manifest.compile(assets)

      # Update the paths to the digest format:
      @collection._cache.merge!(manifest.assets)
    end
  end
end
