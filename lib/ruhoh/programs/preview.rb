module Ruhoh::UI; end
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

      #Ruhoh::Program.watch(ruhoh) if opts[:watch]
      Rack::Builder.new {
        use Rack::Lint
        use Rack::ShowExceptions

        map '/assets' do
          # if collection.previewer?
          #   run collection.load_previewer
          # else
          #   run Rack::Cascade.new(
          #     collection.paths.reverse.map { |path|
          #       Rack::File.new(path)
          #     }
          #   )
          # end
        end

        map '/dash' do
          run Ruhoh::UI::Dashboard.new(ruhoh)
        end

        # The generic Page::Previewer is used to render any/all page-like resources,
        # since they likely have arbitrary urls based on permalink settings.
        map '/' do
          run Ruhoh::Collections::Pages::Previewer.new(ruhoh)
        end
      }
    end
  end
end