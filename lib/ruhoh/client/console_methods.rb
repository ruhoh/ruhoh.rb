class Ruhoh
  module ConsoleMethods
    def reload!
      Ruhoh.setup
      Ruhoh.setup_paths
      Ruhoh.setup_urls
    end
  end
end