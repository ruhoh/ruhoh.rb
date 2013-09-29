module Ruhoh::UI
  class PageNotFound
    Content = <<-TEXT 
# Hello World =D

> A profound quote.

### Fruits I like

- apples
- oranges
- watermelons
- tomatoes
- avocados
TEXT

    def initialize(ruhoh, pointer)
      @ruhoh = ruhoh
      @pointer = pointer
    end

    def call(env)
      @request = Rack::Request.new(env)
      @request.post? ? create : show
    end

    def show
      path = @ruhoh.cascade.find_file('page_not_found')['realpath']
      template = File.open(path, 'r:UTF-8').read
      body = Mustache.render(template, {
        pointer: @pointer,
        url: @request.path,
        filepath: File.join(File.basename(@ruhoh.cascade.base), filepath),
        content: Content
      })

      [404, {'Content-Type' => 'text/html'}, [body]]
    end

    def create
      FileUtils.mkdir_p File.dirname(filepath)
      File.open(filepath, 'w:UTF-8') { |f| f.puts @request.params["body"] }

      sleep 2 # wait for the watcher to pick up the changes (terrible i know)

      response = Rack::Response.new
      response.redirect @request.path
      status, header, body = response.finish
    end

    private

    # Determine the correct filepath from the URL structure.
    # TODO: This if very rudimentary and only works for a stock configuration.
    def filepath
      parts = @request.path.split('/')
      parts.shift # omit root forward slash

      path = (parts.length <= 1) ?
                File.join("_root", (parts.empty? ? "index" : parts.first)) :
                File.join(*parts) # collection

      File.extname(parts.last.to_s).to_s.empty? ?
        (path + @ruhoh.collection(collection_name).config["ext"]) :
        path
    end

    def collection_name
      parts = @request.path.split('/')
      parts.shift # omit root forward slash

      (parts.length <= 1) ? "_root" : parts.first
    end

  end
end
