class Ruhoh
  module Parsers
    module Widgets

      def self.generate
        widgets = Dir[File.join(Ruhoh::Root, 'widgets', "*/*.rb")]
        widgets.each {|f| require f} unless widgets.empty?
                
        Ruhoh::Utils.report('System Widgets', widgets, [])
      end
      
      def self.generate_user_widgets
        widgets = Dir[File.join(Ruhoh.paths.widgets, "*/*.rb")]
        widgets.each {|f| require f} unless widgets.empty?
                
        Ruhoh::Utils.report('User Widgets', widgets, [])
      end
      
    end #Widgets
  end #Parsers
end #Ruhoh