module Ruhoh::Resources::Widgets
  class Collection
    include Ruhoh::Base::Collectable

    def initialize(ruhoh)
      @ruhoh = ruhoh
      @path = File.join(@ruhoh.paths.base, "widgets")
      @system_path = File.join(@ruhoh.paths.system, "widgets")
    end

    def url_endpoint
      "/assets/widgets"
    end

    # @returns[Array] registered widget names.
    def widgets
      names = []
      Array(paths.map{|h| h["path"]}).each do |path|
        namespaced_path = File.join(path, namespace)
        next unless File.directory?(namespaced_path)
        FileUtils.cd(namespaced_path) {
          names += Dir["*"]
        }
      end
      names.uniq
    end
  end
end