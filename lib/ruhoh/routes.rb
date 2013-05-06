class Ruhoh
  class Routes
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end

    def find(route)
      @ruhoh.collections.acting_as_pages.each do |r|
        next unless @ruhoh.collection(r).routes[route]
        return @ruhoh.collection(r).routes[route]
        break
      end

      nil
    end

    # All available routes from pages.
    # This is not cached because the page collections should manage
    # their own cache invalidation strategy
    # @returns[Hash map]
    def all
      routes = {}
      @ruhoh.collections.acting_as_pages.each do |r|
        routes.merge!(@ruhoh.collection(r).routes)
      end
      routes
    end
  end
end