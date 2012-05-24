class Ruhoh
  class Logger
    
    attr_reader :buffer
    attr_accessor :log_file

    def initialize
      @buffer = []
    end
    
    def error(string=nil)
      message = ""
      message << string if string
      message << "\n" unless message[-1] == ?\n
      @buffer << message
      
      self.on_error
    end  
    
    def on_error
      msg = @buffer[0]
      Ruhoh::Friend.say { red msg }
      self.to_file
      exit -1
    end
    
    def to_file
      return unless self.log_file && @buffer.size > 0
      File.open(self.log_file, 'a:UTF-8') { |f|
        f.puts '---'
        f.puts Time.now.utc
        f.puts @buffer.slice!(0..-1).join
      }
    end

  end #Logger
end #Ruhoh