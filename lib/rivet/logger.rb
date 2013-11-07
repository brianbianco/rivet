module Rivet

  module Log

    def self.write(level,message)
      @@log ||= SimpleLogger.instance
      @@log.send(level.to_sym) { message }
    end

    def self.info(message)
      write('info',message)
    end

    def self.debug(message)
      write('debug',message)
    end

    def self.fatal(message)
      write('fatal',message)
    end

    def self.warn(message)
      write('warn',message)
    end

    def self.level(level)
      @@log ||= SimpleLogger.instance
      @@log.level = level
    end

    class SimpleLogger< Logger
      include Singleton

      def initialize
        @dev = Logger::LogDevice.new(STDOUT)
        super @dev
        @progname = "Rivet"
        @formatter = proc do |sev,datetime,name,msg|
          "[#{name}] [#{datetime}] [#{sev}]: #{msg}\n"
        end
        @datetime_format
      end

      def close
        @dev.close
      end
    end

  end
end


