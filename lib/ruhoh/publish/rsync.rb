class Ruhoh
  class Publish::Rsync
    # Deploy via rsync
    # @param[opts] - CLI arguments
    # @param[config] - config hash supplied from publish.yml or publish.json
    #
    # Example publish.json file:
    # {
    #     "rsync": {
    #         "command": nil,
    #         "user": "root",
    #         "host": "12.345.67.891",
    #         "destination": "/var/www/my-site.com"
    #     }
    # }
    #
    # Use "command" to specify a customized rsync command to execute.
    def run(opts={}, config={})
      @config = config
      ruhoh = Ruhoh::Program.compile

      if @config["command"]
        system(@config["command"])
      else
        system('rsync', File.join(ruhoh.config['compiled'], '.'), '-avz', '--delete', '--exclude', '.git', remote)
      end
      FileUtils.rm_r(ruhoh.config['compiled'])
    end

    private

    def remote
      "#{ @config["user"] }@#{ @config["host"] }:#{ @config["destination"] }"
    end
  end
end
