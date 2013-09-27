module Ruhoh::Resources::Widgets
  class Collection
    include Ruhoh::Base::Collectable

    def initialize(ruhoh)
      @ruhoh = ruhoh
      @path = File.join(@ruhoh.cascade.base, "widgets")
      @system_path = File.join(@ruhoh.cascade.system, "widgets")
    end

    def url_endpoint
      "/assets/widgets"
    end

    # @returns[Array] registered widget names.
    def widgets
      names = []
      paths.each do |path|
        FileUtils.cd(path) {
          names += Dir["*"]
        }
      end
      names.uniq
    end
  end
end