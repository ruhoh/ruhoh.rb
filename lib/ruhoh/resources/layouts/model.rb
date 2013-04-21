module Ruhoh::Resources::Layouts
  class Model < Ruhoh::Base::Model
    def generate
      id = File.basename(@pointer['id'], File.extname(@pointer['id']))
      data = parse_layout_file(@pointer['realpath'])
      data
    end
    
    def parse_layout_file(*args)
      path = File.__send__(:join, args)
      raise "Layout file not found: #{path}" unless File.exist?(path)
      data = {}
      page = File.open(path, 'r:UTF-8') {|f| f.read }

      front_matter = page.match(Ruhoh::Utils::FMregex)
      if front_matter
        data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
      end
      
      { 
        "data" => data,
        "content" => page.gsub(Ruhoh::Utils::FMregex, '')
      }
    rescue Psych::SyntaxError => e
      Ruhoh.log.error("ERROR in #{path}: #{e.message}")
      nil
    end
    
  end
end