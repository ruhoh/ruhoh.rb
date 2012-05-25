class Ruhoh
  
  module Utils
    
    FMregex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
    ContentRegex = /\{\{\s*content\s*\}\}/i
    
    def self.parse_file_as_yaml(*args)
      filepath = File.__send__ :join, args
      return nil unless File.exist? filepath

      file = File.open(filepath, 'r:UTF-8') {|f| f.read }
      yaml = YAML.load(file) || {}
      yaml
    rescue Psych::SyntaxError => e
      Ruhoh.log.error("ERROR in #{filepath}: #{e.message}")
      nil
    end
    
    def self.parse_file(*args)
      path = File.__send__(:join, args)
      raise "File not found: #{path}" unless File.exist?(path)

      page = File.open(path, 'r:UTF-8') {|f| f.read }

      front_matter = page.match(FMregex)
      if front_matter
        data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
        data = self.format_meta(data)
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
    
    def self.format_meta(data)
      data['categories'] = Array(data['categories'])
      data['tags'] = Array(data['tags'])
      data
    end

    def self.relative_path(filename)
      filename.gsub(Regexp.new("^#{Ruhoh.paths.site_source}/"), '')
    end
        
    def self.report(name, collection, invalid)
      output = "#{collection.count}/#{collection.count + invalid.count} #{name} processed."
      if collection.empty? && invalid.empty?
        Ruhoh::Friend.say { plain "0 #{name} to process." }
      elsif invalid.empty?
        Ruhoh::Friend.say { green output }
      else
        Ruhoh::Friend.say {
          yellow output
          list "#{name} not processed:", invalid
        }
      end
    end
    
    # Merges hash with another hash, recursively.
    #
    # Adapted from Jekyll which got it from some gem whose link is now broken.
    # Thanks to whoever made it.
    def self.deep_merge(hash1, hash2)
      target = hash1.dup

      hash2.keys.each do |key|
        if hash2[key].is_a? Hash and hash1[key].is_a? Hash
          target[key] = self.deep_merge(target[key], hash2[key])
          next
        end

        target[key] = hash2[key]
      end

      target
    end
    
  end
  
end #Ruhoh