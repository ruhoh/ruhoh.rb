class Ruhoh
  class Cache
    def initialize(ruhoh)
      @__cache = {}
    end

    def __cache
      @__cache
    end

    def set(key, data)
      key = tokenize(key)
      return nil unless key

      @__cache[key] = data
    end

    def get(key)
      key = tokenize(key)
      return nil unless key

      if @__cache[key]
        @__cache[key]
      end
    end

    def delete(key)
      @__cache.delete(tokenize(key))
    end

    private

    def tokenize(key)
      new_key = case key
                when Hash
                  key.to_a.sort.to_s.strip
                when Array
                  key.sort.to_s.strip
                else
                  key.to_s.strip
                end

      new_key.empty? ? nil : new_key
    end
  end
end