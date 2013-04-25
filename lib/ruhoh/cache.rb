class Ruhoh
  class Cache
    def initialize(ruhoh)
      @__cache = {}
    end

    def __cache
      @__cache
    end

    def set(key, data)
      @__cache[key.to_s] = data
    end

    def get(key)
      @__cache[key.to_s]
    end

    def clear(key)
      @__cache.delete(key.to_s)
    end
  end
end