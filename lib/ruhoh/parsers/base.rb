class Ruhoh
  module Parsers

    class Base
      
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
      
      def registered_name
        self.class.name.split("::").last
      end
      
      def generate
        dict = {}
        Array(self.paths).each do |path|
          node = {}
          self.files(path).each { |filename|
            modeler = self.class.const_get(:Modeler).new(@ruhoh, path, filename)
            node.merge!(modeler.generate)
          }
          dict.merge!(node)
        end

        Ruhoh::Utils.report(self.registered_name, dict, [])
        dict
      end
      
      def files(path)
        return [] unless File.directory?(path)
        FileUtils.cd(path) {
          return Dir[self.glob].select { |filename|
            if self.respond_to? :is_valid_page?
              next unless self.is_valid_page?(filename)
            end
            true
          }
        }
      end

    end
    
    module Page
      
      FMregex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      
      def parse_page_file
        FileUtils.cd(@base) do
          raise "File not found: #{path}" unless File.exist?(@id)

          page = File.open(@id, 'r:UTF-8') {|f| f.read }

          front_matter = page.match(FMregex)
          if front_matter
            data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
          else
            data = {}
          end

          return { 
            "data" => data,
            "content" => page.gsub(FMregex, '')
          }
        end
      rescue Psych::SyntaxError => e
        Ruhoh.log.error("ERROR in #{path}: #{e.message}")
        nil
      end
      
    end
    
    class BaseModeler
      def initialize(ruhoh, base, id)
        @ruhoh = ruhoh
        @base = base
        @id = id
      end
    end

  end
end