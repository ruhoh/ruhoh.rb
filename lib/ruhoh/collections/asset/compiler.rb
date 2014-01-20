module Ruhoh::Collections::Asset
  class Compiler
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def run(collection_name)
      pages = @ruhoh.collections.load(collection_name)

      puts "=> Assets for #{collection_name}: #{ pages.count }"
      Ruhoh::Friend.say { cyan "#{collection_name.capitalize}: (#{pages.count} #{collection_name})" }

      manifest = {}
      pages.each do |item|
        digest = Digest::MD5.file(item.realpath).hexdigest

        digest_file = item.id.sub(/\.(\w+)$/) { |ext| "-#{ digest }#{ ext }" }
        manifest[item.id] = digest_file
        compiled_file = @ruhoh.compiled_path(File.join("assets", digest_file))

        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r item.realpath, compiled_file
        Ruhoh::Friend.say { green "  > #{ item.id }" }
      end

      # Update the paths to the digest format:
      @ruhoh.collections.load(collection_name)._cache.merge!(manifest)
    end
  end
end
