module Babylon; module Logger
  class Color
    class Reset
      def self::to_s
        "\e[0m\e[37m"
      end
    end
    
    class Black < Color
      def num; 30; end
    end
    class Red < Color
      def num; 31; end
    end
    class Green < Color
      def num; 32; end
    end
    class Yellow < Color
      def num; 33; end
    end
    class Blue < Color
      def num; 34; end
    end
    class Magenta < Color
      def num; 35; end
    end
    class Cyan < Color
      def num; 36; end
    end
    class White < Color
      def num; 37; end
    end
    
    def self::to_s
      new.to_s
    end
    
    def to_s
      "\e[1m\e[#{num}m"
    end
  end
  
  class << self
    def loglevel=(lvl)
      @@loglevel = case lvl
                   when 'error' then ERROR_LEVEL
                   when 'warn' then WARN_LEVEL
                   when 'info' then INFO_LEVEL
                   when 'debug' then DEBUG_LEVEL
                   end
    end

    def log(lvl, *a)
      if lvl >= (@@loglevel || -1)
        lvlcolors = [Color::Blue, Color::Green, Color::Yellow, Color::Red]
        while lvl > 0 && lvlcolors.size > 1
          lvl -= 1
          lvlcolors.shift
        end
        now = Time.now
        time = now.strftime("%H:%M:%S.") + ((now.to_f - now.to_i) * 1000).to_i.to_s.rjust(4, '0')
        $stderr.puts "#{Color::Cyan}[#{Color::Magenta}#{time}#{Color::Cyan}] " +
          "#{lvlcolors[0]}#{a.join(' ')}#{Color::Reset}"
      end
    end

    ERROR_LEVEL = 3
    def error(*a); log(ERROR_LEVEL, *a) end
    WARN_LEVEL = 2
    def warn(*a); log(WARN_LEVEL, *a) end
    INFO_LEVEL = 1
    def info(*a); log(INFO_LEVEL, *a) end
    DEBUG_LEVEL = 0
    def debug(*a); log(DEBUG_LEVEL, *a) end
  end
end; end
