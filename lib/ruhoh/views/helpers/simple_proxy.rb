module Ruhoh::Views::Helpers
  # Simple proxy object used to responsd to arbitary method calls on an explicit receiver in views.
  #
  # Example:
  #
  # def gist
  #   SimpleProxy.new({
  #     matcher: /^[0-9]+$/,
  #     function: -> input {
  #       "<script src=\"https://gist.github.com/#{ input }.js\"></script>"
  #     }
  #   })
  # end
  #
  # Usage:
  #
  # {{{ gist.12345 }}}
  # 
  # The method "12345" is matched against "matcher" and provided to "function" on success.
  class SimpleProxy
    # @param[opts] Hash
    #  - opts[:matcher] A regular expression to match method calls against.
    #  - opts[:function] The function to execute when successfully called.
    #                    The function takes the name of the method as the input.
    def initialize(opts)
      @opts = opts
    end

    def method_missing(name, *args, &block)
      @opts[:function].call(name.to_s)
    end

    def respond_to?(method)
      method.to_s.match(@opts[:matcher]).nil? ? super : true
    end
  end
end
