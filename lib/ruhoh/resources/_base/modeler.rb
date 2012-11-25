module Ruhoh::Resources::Base
  class Modeler

    def initialize(resource, pointer)
      @resource = resource
      @ruhoh = resource.ruhoh
      # Automatically set which resource type is being used.
      pointer["resource"] = resource.registered_name
      @pointer = pointer
    end
    
    def config
      @ruhoh.db.config(@pointer['resource'])
    end
    
  end
end