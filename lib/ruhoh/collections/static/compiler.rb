module Ruhoh::Collections::Static
  class Compiler
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def run(collection_name)
      pages = @ruhoh.collections.load(collection_name)

      Ruhoh::Friend.say { cyan "#{collection_name.capitalize}: (#{pages.count} #{collection_name})" }

      pages.each do |item|
        ## TODO: HACK get rid of this later.
        parts = item.id.split('/') ; parts.shift

        compiled_file = File.join(@ruhoh.compiled_path(collection_name), parts.join('/'))

        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r item.realpath, compiled_file

        Ruhoh::Friend.say { green "  > #{ item.id }" }
      end
    end
  end
end
