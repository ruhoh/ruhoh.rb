module Ruhoh::Resources::Core::Pages
  class Modeler < Ruhoh::Resources::Core::Base::Modeler
  
    FMregex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
  
    def content
      self.parse_page_file['content']
    end

    def parse_page_file
      raise "File not found: #{@pointer['realpath']}" unless File.exist?(@pointer['realpath'])

      page = File.open(@pointer['realpath'], 'r:UTF-8') {|f| f.read }

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
end