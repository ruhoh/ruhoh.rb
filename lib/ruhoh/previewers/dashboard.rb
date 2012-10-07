class Ruhoh
  module Previewer
    class Dashboard

      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
    
      def call(env)
        template = nil
        [
          @ruhoh.db.config("theme")["path_dashboard_file"],
          @ruhoh.paths.dashboard_file,
          @ruhoh.paths.system_dashboard_file
        ].each do |path|
          template = path and break if File.exist?(path)
        end
        template = File.open(template, 'r:UTF-8') {|f| f.read }
        templater = Ruhoh::Templaters::RMustache.new(@ruhoh)
        output = templater.render(template, @ruhoh.db.payload)
      
        [200, {'Content-Type' => 'text/html'}, [output]]
      end

    end
  end
end