module Ruhoh::Resources
  class Pages < Resource
    
    def config
      hash = super
      hash['layout'] ||= 'page'
      hash['exclude'] = Array(hash['exclude']).map {|node| Regexp.new(node) }
      hash
    end
    
    def compile(id=nil)
      datas = if id
        [ @ruhoh.db.__send__(self.namespace)[id] ].compact
      else
        @ruhoh.db.__send__(self.namespace).each_value
      end

      datas.each do |data|
        modeler.new(self, data["pointer"]).compile
      end

      nil
    end
    

    class Modeler < BaseModeler
      include Page
      
      # Generate this filepath
      # Returns data to be registered to the database
      def generate
        parsed_page     = self.parse_page_file
        data            = parsed_page['data']
        data['pointer'] = @pointer
        data['id']      = @pointer['id']
        data['url']     = self.permalink(data)
        data['title']   = data['title'] || self.to_title
        data['layout']  = config['layout'] unless data['layout']

        # Register this route for the previewer
        @ruhoh.db.routes[data['url']] = @pointer

        {
          "#{@pointer['id']}" => data
        }
      end
    
      def to_title
        name = File.basename( @pointer['id'], File.extname(@pointer['id']) )
        name = @pointer['id'].split('/')[-2] if name == 'index' && !@pointer['id'].index('/').nil?
        name.gsub(/[^\p{Word}+]/u, ' ').gsub(/\b\w/){$&.upcase}
      end
  
      # Build the permalink for the given page.
      # Only recognize extensions registered from a 'convertable' module.
      # This means 'non-convertable' extensions should pass-through.
      #
      # Returns [String] the permalink for this page.
      def permalink(page)
        ext = File.extname(page['id'])
        name = page['id'].gsub(Regexp.new("#{ext}$"), '')
        ext = '.html' if Ruhoh::Converter.extensions.include?(ext)
        url = name.split('/').map {|p| Ruhoh::Utils.to_url_slug(p) }.join('/')
        url = "#{url}#{ext}".gsub(/index.html$/, '')
        if page['permalink'] == 'pretty' || config['permalink'] == 'pretty'
          url = url.gsub(/\.html$/, '')
        end
      
        url = '/' if url.empty?
        @ruhoh.to_url(url)
      end
      
      def compile
        pointer = @pointer
        FileUtils.cd(@ruhoh.paths.compiled) {
          page = @ruhoh.page(@pointer)
          FileUtils.mkdir_p File.dirname(page.compiled_path)
          File.open(page.compiled_path, 'w:UTF-8') { |p| p.puts page.render_full }
          Ruhoh::Friend.say { green "processed: #{pointer['id']}" }
        }
      end
    end

    class Watcher
      def initialize(resource)
        @resource = resource
        @ruhoh = resource.ruhoh
      end
      
      def match(path)
        path =~ %r{^#{@resource.path}}
      end
      
      def update(path)
        path = path.gsub(/^.+\//, '')
        key = @ruhoh.db.routes.key(path)
        @ruhoh.db.routes.delete(key)
        @ruhoh.db.update("type" => type, "id" => path)
      end
    end
    
    class Client
      Help = [
        {
          "command" => "new <path>",
          "desc" => "Create a new page at the given path.",
        },
        {
          "command" => "list",
          "desc" => "List all pages.",
        }
      ]

      def initialize(ruhoh, data)
        @ruhoh = ruhoh
        @args = data[:args]
        @options = data[:options]
        @opt_parser = data[:opt_parser]
        @options.ext = (@options.ext || 'md').gsub('.', '')
      end
      
      def new
        ruhoh = @ruhoh
        name = @args[2]
        Ruhoh::Friend.say { 
          red "Please specify a path"
          plain "  ex: ruhoh pages new projects/hello-world"
          exit
        } if (name.nil? || name.gsub(/\s/, '').empty?)

        filename = File.join(@ruhoh.paths.base, "pages", name.gsub(/\s/, '-'))
        filename = File.join(filename, "index.#{@options.ext}") if File.extname(filename) == ""
        if File.exist?(filename)
          abort("Create new page: aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
        end

        FileUtils.mkdir_p File.dirname(filename)
        File.open(filename, 'w:UTF-8') do |page|
          page.puts @ruhoh.db.scaffolds['page.html'].to_s
        end

        Ruhoh::Friend.say { 
          green "New page:"
          plain ruhoh.relative_path(filename)
        }
      end
      
      # List pages
      def list
        data = @ruhoh.db.posts

        if @options.verbose
          Ruhoh::Friend.say {
            data.each_value do |p|
              cyan("- #{p['id']}")
              plain("  title: #{p['title']}") 
              plain("  url: #{p['url']}")
            end
          }
        else
          Ruhoh::Friend.say {
            data.each_value do |p|
              cyan("- #{p['id']}")
            end
          }
        end
      end
      
    end

  end
end