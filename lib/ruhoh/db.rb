class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB
    WhiteList = [:site, :posts, :pages, :routes, :layouts, :partials, :widgets, :assets]

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
          when :assets
            Ruhoh::Parsers::Assets.generate
          else
            raise "Data type: '#{name}' is not a valid data type."
          end
        )
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