require 'ruhoh/resources_interface'
class Ruhoh
  class Routes
    attr_reader :routes

    def initialize(ruhoh)
      @ruhoh = ruhoh
      @routes = {}
    end

    def process_all
      @ruhoh.resources.acting_as_pages.each do |r|
        @ruhoh.resources.load_collection(r).dictionary
      end

      @routes
    end

    def get_pointer(route)
      @routes[route]
    end

    def add(route, pointer)
      @routes[route] = pointer
    end

    def delete(route)
      @routes.delete(route)
    end

    def exists?(route)
      @routes.key?(route)
    end
    alias_method :exist?, :exists?
  end
end