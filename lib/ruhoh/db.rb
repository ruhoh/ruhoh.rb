# Require all the parsers
Dir[File.join(File.dirname(__FILE__), 'parsers','*.rb')].each { |f|
  require f
}

class Ruhoh
  # Public: Database class for interacting with "data" in Ruhoh.
  class DB
    WhiteList = [:site, :posts, :pages, :routes, :layouts, :partials, :widgets, :theme_config, :stylesheets, :javascripts, :payload, :scaffolds]

    self.__send__ :attr_reader, *WhiteList
    
    def initialize(ruhoh)
      @ruhoh = ruhoh
    end
    
    def update(name)
      camelized_name = name.to_s.split('_').map {|a| a.capitalize}.join
      self.instance_variable_set("@#{name}",
        Ruhoh::Parsers.const_get(camelized_name).generate(@ruhoh)
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
    
  end #DB
end #Ruhoh