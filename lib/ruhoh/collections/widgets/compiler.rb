module Ruhoh::Collections::Widgets
  class Compiler
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def run(collection_name)
      pages = @ruhoh.collections.load(collection_name)
      widgets_used = pages._widgets_used.to_a

      Ruhoh::Friend.say { 
        cyan "#{collection_name.capitalize}: (#{pages.count} #{collection_name})"
        cyan "  Actually used: #{ widgets_used }"
      }

      pages.each do |item|
        next if item.ext == ".html"
        next unless widgets_used.include?(item.directories[1])

        compiled_file = @ruhoh.compiled_path(File.join("assets", item.id))

        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r item.realpath, compiled_file
        Ruhoh::Friend.say { green "  > #{ item.id }" }
      end
    end
  end
end
