module Ruhoh::Resources::Page
  class Compiler < Ruhoh::Resources::Base::Compiler
    def run
      pages = @ruhoh.db.__send__(resource_name)
      resource_name = self.resource_name
      Ruhoh::Friend.say { cyan "#{resource_name.capitalize}: (#{pages.count} #{resource_name})" }
      
      FileUtils.cd(@ruhoh.paths.compiled) {
        pages.each_value { |data|
          view = @ruhoh.master_view(data['pointer'])

          FileUtils.mkdir_p File.dirname(view.compiled_path)
          File.open(view.compiled_path, 'w:UTF-8') { |p| p.puts view.render_full }

          Ruhoh::Friend.say { green "  -> #{data['id']}" }
        }
      }
    end
  end
end
