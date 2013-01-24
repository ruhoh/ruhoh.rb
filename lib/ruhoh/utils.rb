class Ruhoh
  module Utils
    
    FMregex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
    
    def self.parse_yaml_file(*args)
      filepath = File.__send__ :join, args
      return nil unless File.exist? filepath

      file = File.open(filepath, 'r:UTF-8') {|f| f.read }
      yaml = YAML.load(file) || {}
      yaml
    rescue Psych::SyntaxError => e
      Ruhoh.log.error("ERROR in #{filepath}: #{e.message}")
      nil
    end
    
    def self.url_to_path(url, base=nil)
      url = url.gsub(/^\//, '')
      parts = url.split('/')
      parts = parts.unshift(base) if base
      File.__send__(:join, parts)
    end    
    
    def self.to_url_slug(title)
      CGI::escape self.to_slug(title)
    end
    
    # My Post Title ===> my-post-title
    def self.to_slug(title)
      title = title.to_s.downcase.strip.gsub(/[^\p{Word}+]/u, '-')
      title.gsub(/^\-+/, '').gsub(/\-+$/, '').gsub(/\-+/, '-')
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
    
    def self.constantize(class_name)
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ class_name
        raise NameError, "#{class_name.inspect} is not a valid constant name!"
      end

      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end
    
    # Thanks ActiveSupport: http://stackoverflow.com/a/1509939/101940
    def self.underscore(string)
      string.
      to_s.
      gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end
    
  end
end #Ruhoh