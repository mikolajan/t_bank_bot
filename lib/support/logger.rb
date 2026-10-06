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
  end
end
