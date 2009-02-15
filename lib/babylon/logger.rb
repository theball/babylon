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
        $stderr.puts "#{Color::Cyan}[#{Color::Magenta}#{elapsed_time}#{Color::Cyan}] " +
          "#{lvlcolors[0]}#{a.join(' ')}#{Color::Reset}"
      end
    end

    @@log_starttime ||= Time.now
    def elapsed_time
      elapsed = Time.now - @@log_starttime
      h, m = 0, 0
      while elapsed >= 60 * 60
        h += 1
        elapsed -= 60 * 60
      end
      while elapsed >= 60
        m += 1
        elapsed -= 60
      end
      time = format("%02d:%02d:%07.4f", h, m, elapsed)
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
