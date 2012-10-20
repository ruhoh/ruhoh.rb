class Ruhoh
  module Program
    
    # Public: A program for running ruhoh as a rack application
    # which renders singular pages via their URL.
    # 
    # Examples
    #
    #  In config.ru:
    #
    #   require 'ruhoh'
    #   run Ruhoh::Program.preview
    #
    # Returns: A new Rack builder object which should work inside config.ru
    def self.preview(opts={})
      opts[:watch] ||= true
      opts[:env] ||= 'development'
      
      ruhoh = Ruhoh.new
      ruhoh.setup
      ruhoh.config['env'] = opts[:env]
      ruhoh.setup_paths
      ruhoh.setup_plugins unless opts[:enable_plugins] == false

      # initialize the routes dictionary
      ruhoh.db.pages
      ruhoh.db.posts
      
      Ruhoh::Watch.start(ruhoh) if opts[:watch]
      Rack::Builder.new {
        use Rack::Lint
        use Rack::ShowExceptions
        
        ruhoh.db.urls.each do |name, url|
          next if ["javascripts", "stylesheets", "base_path"].include?(name)
          plugin = Ruhoh::Plugins::Base.plugins[name]
          next unless plugin

          map url do
            if plugin.const_defined?(:Previewer)
              run plugin.const_get(:Previewer).new(ruhoh)
            else
              run Rack::File.new(File.join(ruhoh.paths.base, ruhoh.db.paths[name]))
            end
          end
        end
        
        map '/' do
          run Ruhoh::Previewer::Page.new(ruhoh)
        end
      }
    end
    
    # Public: A program for compiling to a static website.
    # The compile environment should always be 'production' in order
    # to properly omit drafts and other development-only settings.
    def self.compile(target)
      ruhoh = Ruhoh.new
      ruhoh.setup
      ruhoh.config['env'] = 'production'
      ruhoh.setup_paths
      ruhoh.setup_plugins
      
      if target
        ruhoh.paths.compiled = File.expand_path(target)
      elsif ruhoh.config.compiled
        ruhoh.paths.compiled = ruhoh.config.compiled
      end
      
      Ruhoh::Compiler.compile(ruhoh)
    end
    
  end #Program
end #Ruhoh