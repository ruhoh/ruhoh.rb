module Ruhoh::Templaters  
  # The master view for primary template that everything renders into.
  class Master < RMustache
    include PageHelpers
    
    # Delegate #page to the kind of resource this view is modeling.
    def page
      return @page if @page
      parser = context["pointer"]["parser"] rescue nil
      return "" unless parser
      @page = parser ? 
        Ruhoh::Templaters.const_get("#{parser.capitalize}Helpers").new(@ruhoh, context) :
        nil
    end

  end
end
