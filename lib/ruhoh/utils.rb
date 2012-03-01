class Ruhoh
  
  module Utils
    
    FMregex = /^---\n(.|\n)*---\n/
    ContentRegex = /\{\{\s*content\s*\}\}/i
    
    def self.parse_file(file_path)
      page = File.open(file_path).read
      front_matter = page.match(FMregex)
      raise "Invalid Frontmatter" unless front_matter

      data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
      content = page.gsub(FMregex, '')
    
      [data, content]
    end
  
  end
  
end #Ruhoh