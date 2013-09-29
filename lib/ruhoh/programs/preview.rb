require 'ruhoh/programs/watch'
require 'ruhoh/ui/dashboard'
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
      ruhoh.env = opts[:env]
      ruhoh.setup_plugins unless opts[:enable_plugins] == false

      # initialize the routes dictionary for all page resources.
      ruhoh.routes.all

      Ruhoh::Program.watch(ruhoh) if opts[:watch]
      Rack::Builder.new {
        use Rack::Lint
        use Rack::ShowExceptions

        # Url endpoints as registered by the resources.
        # The urls are mapped to the resource's individual rack-compatable Previewer class.
        # Note page-like resources (posts, pages) don't render uniform url endpoints,
        # since presumably they define customized permalinks per singular resource.
        # Page-like resources are handled the root mapping below.
        ruhoh.collections.url_endpoints_sorted.each do |h|
          # Omit theme because they are special use-cases.
          next if %w{ theme }.include?(h["name"])
          map h["url"] do
            collection = ruhoh.collection(h["name"])
            if collection.previewer?
              run collection.load_previewer
            else
              run Rack::Cascade.new(
                collection.paths.reverse.map { |path|
                  Rack::File.new(path)
                }
              )
            end
          end
        end

        map '/dash' do
          run Ruhoh::UI::Dashboard.new(ruhoh)
        end

        # The generic Page::Previewer is used to render any/all page-like resources,
        # since they likely have arbitrary urls based on permalink settings.
        map '/' do
          run Ruhoh::Resources::Pages::Previewer.new(ruhoh)
        end
      }
    end
  end
end