module Ruhoh::Collections::Widgets
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
        next if item.ext == ".html"

        compiled_file = @ruhoh.compiled_path(File.join("assets", item.id))

        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r item.realpath, compiled_file
        Ruhoh::Friend.say { green "  > #{ item.id }" }
      end
    end
  end
end
