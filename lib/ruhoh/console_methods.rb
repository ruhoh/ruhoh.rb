class Ruhoh
  module ConsoleMethods
    class << self
      attr_accessor :env
    end
    
    def ruhoh
      return @ruhoh if @ruhoh
      @ruhoh = Ruhoh.new
      @ruhoh.env = ConsoleMethods.env || 'development'
      @ruhoh
    end

    def reload!
      @ruhoh = nil
      self.ruhoh
    end
  end
end