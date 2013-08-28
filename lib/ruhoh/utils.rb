class Ruhoh
  module Utils

    def self.url_to_path(url, base=nil)
      url = url.gsub(/^\//, '')
      parts = url.split('/')
      parts = parts.unshift(base) if base
      File.__send__(:join, parts)
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
  end
end
