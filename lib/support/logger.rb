require 'logger'

module Support
  module Logger
    def self.logger
      @logger ||= ::Logger.new($stdout).tap do |log|
        log.formatter = proc do |severity, datetime, _progname, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] [#{severity}] #{msg}\n"
        end
        log.level = ENV.fetch('LOG_LEVEL', 'INFO')
      end
    end

    # \r moves the cursor to the beginning, \e[K clears the line to the end
    def self.update_line(msg)
      $stdout.print "\r#{msg}\e[K"
      $stdout.flush
    end
  end
end
