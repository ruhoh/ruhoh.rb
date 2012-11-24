module Ruhoh::Resources::Theme
  class Watcher
    def initialize(resource)
      @resource = resource
      @ruhoh = resource.ruhoh
    end
  
    def match(path)
      path =~ Regexp.new("^#{@resource.path}")
    end
  
    def update(path)
      @ruhoh.db.clear(:stylesheets)
      @ruhoh.db.clear(:javascripts)
      @ruhoh.db.clear(:widgets)
      @ruhoh.db.clear(:layouts)
    end
  end
end