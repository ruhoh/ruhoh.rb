class Ruhoh
  module Compiler
    class Pages
      
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
      
      def run
        FileUtils.cd(@ruhoh.paths.compiled) {
          @ruhoh.db.all_pages.each_value do |p|
            page = @ruhoh.page(p['id'])

            FileUtils.mkdir_p File.dirname(page.compiled_path)
            File.open(page.compiled_path, 'w:UTF-8') { |p| p.puts page.render }

            Ruhoh::Friend.say { green "processed: #{p['id']}" }
          end
        }
      end

    end
  end
end