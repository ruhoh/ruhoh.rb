class Ruhoh
  module Program
    # Public: A program for compiling to a static website.
    # The compile environment should always be 'production' in order
    # to properly omit drafts and other development-only settings.
    def self.compile(target=nil)
      ruhoh = Ruhoh.new
      ruhoh.setup
      ruhoh.env = 'production'
      ruhoh.setup_paths
      ruhoh.setup_plugins
      
      if target
        ruhoh.paths.compiled = File.expand_path(target)
      elsif ruhoh.config["compiled"]
        ruhoh.paths.compiled = ruhoh.config["compiled"]
      end

      ruhoh.compile

      ruhoh
    end
  end
end