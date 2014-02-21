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

    def path(arg)
      super(((arg == "_root") ? "" : arg))
    end

    # Include the root directory as part of allowable collections
    def list
      %w{ _root } + super 
    end

    # Handle special "_root" case
    # TODO: Remove hard-coded stuff
    def _root
      special_files = %w(config Gemfile publish page_not_found dashboard)
      path("_root").where("$shortname" => { "$nin" => special_files })
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
