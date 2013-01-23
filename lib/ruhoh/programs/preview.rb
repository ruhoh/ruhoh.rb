require 'ruhoh/programs/watch'
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
      ruhoh.env = opts[:env]
      ruhoh.setup_paths
      ruhoh.setup_plugins unless opts[:enable_plugins] == false

      # initialize the routes dictionary
      ruhoh.db.pages
      ruhoh.db.posts
      
      Ruhoh::Program.watch(ruhoh) if opts[:watch]
      Rack::Builder.new {
        use Rack::Lint
        use Rack::ShowExceptions
        
        sorted_urls = ruhoh.db.urls.each.map {|k, v| {"name" => k, "url" => v} }
        sorted_urls = sorted_urls.sort { |a, b| b["url"].length <=> a["url"].length }
        sorted_urls.each do |h|
          next if h["name"] == "base_path"
          next unless ruhoh.resources.exists?(h["name"])
          map h["url"] do
            if ruhoh.resources.previewer?(h["name"])
              run ruhoh.resources.load_previewer(h["name"])
            else
              realpath = (ruhoh.db.paths[h["name"]] =~ %r{^#{ruhoh.paths.base}}) ?
                         ruhoh.db.paths[h["name"]] :
                         File.join(ruhoh.paths.base, ruhoh.db.paths[h["name"]])
              run Rack::File.new(realpath)
            end
          end
        end
        
        map '/' do
          run Ruhoh::Resources::Page::Previewer.new(ruhoh)
        end
      }
    end
  end
end