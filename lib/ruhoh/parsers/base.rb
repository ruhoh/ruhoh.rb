class Ruhoh
  module Parsers

    class Base
      
      def initialize(ruhoh)
        @ruhoh = ruhoh
      end
      
      # Default paths to the 3 levels of the cascade.
      def paths
        [@ruhoh.paths.system, @ruhoh.paths.base, @ruhoh.paths.theme]
      end
      
      def registered_name
        self.class.name.split("::").last
      end
      
      # Generate each data 
      # Each data can have 3 references, one per each cascade level.
      # They will overwrite eachother successviely if found.
      def generate
        dict = {}
        self.files.each { |obj|
          modeler = self.class.const_get(:Modeler).new(@ruhoh, obj)
          dict.merge!(modeler.generate)
        }
        Ruhoh::Utils.report(self.registered_name, dict, [])
        dict
      end

      # Generate a single instance given the filename (id)
      def generate_by_id(id)
        dict = {}
        self.files_by_id(id).each { |file_hash|
          modeler = self.class.const_get(:Modeler).new(@ruhoh, file_hash)
          dict.merge!(modeler.generate)
        }
        dict
      end
      
      # Find all valid files for this data in the system.
      # Returns array of file data hashes
      def files
        a = []
        Array(self.paths).each do |path|
          next unless File.directory?(path)
          FileUtils.cd(path) {
            Dir[self.glob].each { |filename|
              if self.respond_to? :is_valid_page?
                next unless self.is_valid_page?(filename)
              end
              a << {
                realpath: File.realpath(filename),
                id: filename
              }
            }
          }
        end
        a
      end
      
      # Find all valid file objects based on a file "id"
      # Returns array of file objects. can be many
      # due to the cascade.
      def files_by_id(id)
        a = []
        Array(self.paths).each do |path|
          next unless File.directory?(path)
          FileUtils.cd(path) {
            next unless File.exist? id
            next unless self.is_valid_page?(id)
            a << {
              realpath: File.realpath(id),
              id: id
            }
          }
        end
        a
      end
      
    end
    
    module Page
      
      FMregex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      
      def parse_page_file
        raise "File not found: #{@realpath}" unless File.exist?(@realpath)

        page = File.open(@realpath, 'r:UTF-8') {|f| f.read }

        front_matter = page.match(FMregex)
        if front_matter
          data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
        else
          data = {}
        end

        {
          "data" => data,
          "content" => page.gsub(FMregex, '')
        }
      rescue Psych::SyntaxError => e
        Ruhoh.log.error("ERROR in #{path}: #{e.message}")
        nil
      end
      
    end
    
    class BaseModeler
      def initialize(ruhoh, file_hash)
        @ruhoh = ruhoh
        @realpath = file_hash[:realpath]
        @base = file_hash[:realpath]
        @id = file_hash[:id]
      end
    end

  end
end