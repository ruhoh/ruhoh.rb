module Ruhoh::Resources::Page
  class Compiler < Ruhoh::Resources::Base::Compiler
    def run
      FileUtils.cd(@ruhoh.paths.compiled) {
        @ruhoh.db.__send__(resource_name).each_value { |data|
          
          view = @ruhoh.master_view(data['pointer'])

          FileUtils.mkdir_p File.dirname(view.compiled_path)
          File.open(view.compiled_path, 'w:UTF-8') { |p| p.puts view.render_full }

          Ruhoh::Friend.say { green "processed: #{data['id']}" }
        }
      }
    end
  end
end
