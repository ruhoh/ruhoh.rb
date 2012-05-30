class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB
    WhiteList = [:site, :posts, :pages, :routes, :layouts, :partials, :widgets, :stylesheets, :javascripts, :payload]

    class << self
      self.__send__ :attr_reader, *WhiteList

      def update(name)
        self.instance_variable_set("@#{name}", 
          case name
          when :site
            Ruhoh::Parsers::Site.generate
          when :routes
            Ruhoh::Parsers::Routes.generate
          when :posts
            Ruhoh::Parsers::Posts.generate
          when :pages
            Ruhoh::Parsers::Pages.generate
          when :layouts
            Ruhoh::Parsers::Layouts.generate
          when :partials
            Ruhoh::Parsers::Partials.generate
          when :widgets
            Ruhoh::Parsers::Widgets.generate
          when :stylesheets
            Ruhoh::Parsers::Stylesheets.generate
          when :javascripts
            Ruhoh::Parsers::Javascripts.generate
          when :payload
            Ruhoh::Parsers::Payload.generate
          else
            raise "Data type: '#{name}' is not a valid data type."
          end
        )
      end
      
      # Always regenerate a fresh payload since it
      # references other generated data.
      def payload
        self.update(:payload)
        @payload
      end
      
      def all_pages
        self.posts['dictionary'].merge(self.pages)
      end
      
      def update_all
        WhiteList.each do |var|
          self.__send__(:update, var)
        end
      end
      
    end #self
  end #DB
end #Ruhoh