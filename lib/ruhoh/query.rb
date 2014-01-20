class Ruhoh
  class Query < Silly::Query
    @paths = Set.new
    class  << self
      attr_reader :paths
      def append_path(path)
        @paths << path
      end
    end

    def initialize
      super
      @paths = self.class.paths
    end

    def published
      where("$directories" => { "$ne" => "drafts" })
    end

    def drafts
      where("$directories" => "drafts")
    end

    def valid
      where("$filename" => {"$exclude" => /(config.yml|config.yaml|config.yml|^[\._])/ })
      #excludes = Array(config['exclude']).map { |node| Regexp.new(node) }
      #excludes.each { |regex| return false if filepath =~ regex }
    end
  end
end
