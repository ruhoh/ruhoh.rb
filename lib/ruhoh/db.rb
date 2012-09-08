require 'ruhoh/parsers/posts'
require 'ruhoh/parsers/pages'
require 'ruhoh/parsers/routes'
require 'ruhoh/parsers/layouts'
require 'ruhoh/parsers/partials'
require 'ruhoh/parsers/widgets'
require 'ruhoh/parsers/theme_config'
require 'ruhoh/parsers/stylesheets'
require 'ruhoh/parsers/javascripts'
require 'ruhoh/parsers/payload'
require 'ruhoh/parsers/site'
require 'ruhoh/parsers/scaffolds'

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
    #rescue NameError
    #  raise NameError, "Data type: '#{name}' is not a valid data type."
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