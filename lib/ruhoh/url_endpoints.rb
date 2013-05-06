class Ruhoh
  class UrlEndpoints

    def initialize(ruhoh)
      @ruhoh = ruhoh
      @urls = {}
    end

    def urls
      @urls["base_path"] = @ruhoh.base_path
      return @urls if @urls.keys.length > 1 # consider base_url

      @ruhoh.collections.all.each do |name|
        collection = @ruhoh.collections.load_collection(name)
        next unless collection.respond_to?(:url_endpoint)
        @urls[name] = @ruhoh.to_url(collection.url_endpoint)
      end

      @urls
    end

    def sorted
      sorted_urls = urls.each.map {|k, v| {"name" => k, "url" => v} }
      sorted_urls.sort { |a, b| b["url"].length <=> a["url"].length }
    end
  end
end