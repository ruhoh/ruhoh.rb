module Ruhoh::Resources::Page
  class Compiler < Ruhoh::Resources::Base::Compiler
    def run
      FileUtils.cd(@ruhoh.paths.compiled) {
        @ruhoh.db.__send__(resource_name).each_value { |data|
          
          page = @ruhoh.page(data['pointer'])

          FileUtils.mkdir_p File.dirname(page.compiled_path)
          File.open(page.compiled_path, 'w:UTF-8') { |p| p.puts page.render_full }

          Ruhoh::Friend.say { green "processed: #{data['id']}" }
        }
      }
    end
  end
end
