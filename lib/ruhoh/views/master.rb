module Ruhoh::Views
  # The master view for primary template that everything renders into.
  class Master < RMustache
    include Ruhoh::Views::Helpers::Page
    
    # Delegate #page to the kind of resource this view is modeling.
    def page
      return @page if @page
      resource = context["pointer"]["resource"] rescue nil
      return "" unless resource
      
      @page = resource ? 
        Ruhoh::Resources::Resource.resources[resource].const_get(:View).new(@ruhoh, context) :
        nil
    end

  end
end
