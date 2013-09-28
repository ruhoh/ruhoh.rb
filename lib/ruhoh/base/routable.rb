# Makes a collection routable.
module Ruhoh::Base::Routable
  def routes
    return @routes if @routes
    @routes = {}
    dictionary
    @routes
  end

  def routes_add(route, pointer)
    @routes ||= {}
    @routes[route] = pointer
  end

  def routes_delete(pointer)
    return unless @routes
    route = @routes.find{ |k, v| v == pointer }
    @routes.delete(route[0]) if route
  end
end
