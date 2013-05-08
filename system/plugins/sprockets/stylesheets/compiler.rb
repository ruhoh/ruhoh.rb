require 'sprockets'
module Ruhoh::Resources::Stylesheets
  class Compiler
    include Ruhoh::Base::Compilable

    def run
      Ruhoh::Friend.say { cyan "Stylesheets: (using sprockets)" }
      env = Sprockets::Environment.new
      env.logger = Logger.new(STDOUT)
      @collection.paths.reverse.each do |h|
        env.append_path(File.join(h["path"], @collection.resource_name))
      end
      
      compiled_path = Ruhoh::Utils.url_to_path(@collection.url_endpoint, @ruhoh.paths.compiled)
      FileUtils.mkdir_p compiled_path

      manifest = Sprockets::Manifest.new(env, compiled_path)
      assets = @collection.files.values.map{ |p| p["id"] }
      puts assets.inspect
      manifest.compile(assets)

      # Update the stylesheet paths to the digest format:
      @collection._cache.merge!(manifest.assets)
    end
  end
end
