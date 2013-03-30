require 'sprockets'
module Ruhoh::Resources::Javascripts
  class Compiler < Ruhoh::Base::Assets::Compiler
    def run
      Ruhoh::Friend.say { cyan "Javascripts: (using sprockets)" }
      env = Sprockets::Environment.new
      env.logger = Logger.new(STDOUT)
      @collection.paths.reverse.each do |h|
        env.append_path(File.join(h["path"], @collection.namespace))
      end

      compiled_path = Ruhoh::Utils.url_to_path(@ruhoh.db.urls["javascripts"], @ruhoh.paths.compiled)
      FileUtils.mkdir_p compiled_path

      manifest = Sprockets::Manifest.new(env, compiled_path)
      assets = @collection.files.map{ |p| p["id"] }
      manifest.compile(assets)

      # Update the stylesheet paths to the digest format:
      collection_view = @ruhoh.resources.load_collection_view("javascripts")
      collection_view._cache.merge!(manifest.assets)
    end
  end
end
