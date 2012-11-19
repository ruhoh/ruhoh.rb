class Ruhoh
  module Compiler
    class Pages
      
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
      
      def run
        FileUtils.cd(@ruhoh.paths.compiled) {
          @ruhoh.db.pages.each_value do |data|
            
            page = @ruhoh.page(data['pointer'])

            FileUtils.mkdir_p File.dirname(page.compiled_path)
            File.open(page.compiled_path, 'w:UTF-8') { |p| p.puts page.render_full }

            Ruhoh::Friend.say { green "processed: #{data['id']}" }
          end
        }
      end

    end
  end
end