class Ruhoh
  
  module Utils
    
    FMregex = /^---\n(.|\n)*---\n/
    ContentRegex = /\{\{\s*content\s*\}\}/i
    
    def self.parse_file_as_yaml(*args)
      filepath = File.__send__ :join, args
      return nil unless File.exist? filepath

      file = File.open(filepath)
      yaml = YAML.load(file) || {}
      file.close  
      
      yaml
    end
    
    # Relative file_path from site_source
    def self.parse_file(*args)
      path = File.__send__ :join, args

      raise "File not found: #{path}" unless File.exist?(path)

      page = File.open(path).read
      front_matter = page.match(FMregex)

      return {} unless front_matter

      data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}

      { 
        "data" => data, 
        "content" => page.gsub(FMregex, '')
      }
    end
  
  end
  
end #Ruhoh