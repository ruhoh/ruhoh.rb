class Ruhoh

  # The Friend is good for conversation.
  # He tells you what's going on.
  # Implementation is largely copied from rspec gem: http://rspec.info/
  class Friend
    
    class << self
      
      def say(&block)
        self.instance_eval(&block)
      end
    
      # TODO: Adds ability to disable if color is not supported?
      def color_enabled?
        true
      end
      
      def list(caption, listings)
        red("  " + caption)
        listings.each do |pair|
          cyan("    - " + pair[0])
          cyan("      " + pair[1])
        end
      end
      
      def color(text, color_code)
        puts color_enabled? ? "#{color_code}#{text}\e[0m" : text
      end

      def plain(text)
        puts text
      end
      
      def bold(text)
        color(text, "\e[1m")
      end

      def red(text)
        color(text, "\e[31m")
      end

      def green(text)
        color(text, "\e[32m")
      end

      def yellow(text)
        color(text, "\e[33m")
      end

      def blue(text)
        color(text, "\e[34m")
      end

      def magenta(text)
        color(text, "\e[35m")
      end

      def cyan(text)
        color(text, "\e[36m")
      end

      def white(text)
        color(text, "\e[37m")
      end
      
    end #self
    
  end #Friend

end #Ruhoh