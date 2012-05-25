class Ruhoh
  module Parsers
    module Widgets
    
      # Process available widgets into widget dictionary.
      #
      # Returns Dictionary of widget data.
      def self.generate
        widgets = {}
        self.widgets.each do |name|
          config = self.process_config(name)
          widgets[name] = {
            'name' => name,
            'config' => config,
            'scripts' => self.process_scripts(config, name),
            'layout' => self.process_layout(config, name)
          }
        end
        Ruhoh::Utils.report('Widgets', widgets, [])

        widgets
      end

      # Find the widgets.
      #
      # Returns Array of widget names.
      def self.widgets
        names = []
        FileUtils.cd(Ruhoh.paths.widgets) { names += Dir["*"] }
        FileUtils.cd(Ruhoh.paths.system_widgets) { names += Dir["*"] }
        names.uniq!
        names
      end
      
      # Process the widget configuration params.
      #
      # Returns Hash of configuration params.
      def self.process_config(widget_name)
        system_config = Ruhoh::Utils.parse_file_as_yaml(Ruhoh.paths.system_widgets, widget_name, Ruhoh.names.base_config) || {}
        user_config = Ruhoh::Utils.parse_file_as_yaml(Ruhoh.paths.widgets, widget_name, Ruhoh.names.base_config) || {}
        config = Ruhoh::Utils.deep_merge(system_config, user_config)
        config['layout'] ||= widget_name
        config['stylesheet'] ||= widget_name
        config
      end
      
      # Process widget script dependencies.
      # Script dependencies may be set in the config.
      # Look for default script at: scripts/{widget_name}.js if no config.
      # If found, we include it, else no scripts will load.
      #
      # Returns Array of script filenames to load.
      def self.process_scripts(config, widget_name)
        scripts = config['scripts'] ? Array(config['scripts']) : []
        
        # Try for the default script if no config.
        if scripts.empty?
          script_file = File.join(Ruhoh.paths.widgets, widget_name, 'scripts', "#{widget_name}.js")
          if File.exist?(script_file)
            scripts << "#{widget_name}.js"
          else
            script_file = File.join(Ruhoh.paths.system_widgets, widget_name, 'scripts', "#{widget_name}.js")
            scripts << "#{widget_name}.js" if File.exist?(script_file)
          end
        end
        
        scripts
      end
      
      # Determine and process the correct widget layout.
      # The layout may be configured by the user or system.
      #
      # Returns String of rendered layout content.
      def self.process_layout(config, widget_name)
        layout = File.join(Ruhoh.paths.widgets, widget_name, 'layouts', "#{config['layout']}.html")
        unless File.exist?(layout)
          layout = File.join(Ruhoh.paths.system_widgets, widget_name, 'layouts', "#{config['layout']}.html")
        end
        return '' unless File.exist?(layout)

        content = File.open(layout, 'r:UTF-8') { |f| f.read }
        Mustache.render(content, {'config' => config})
      end
      
    end #Widgets
  end #Parsers
end #Ruhoh