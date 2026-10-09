require 'tty-prompt'

module Support
  module Prompt
    def self.prompt
      @prompt ||= TTY::Prompt.new(interrupt: :exit, symbols: { marker: '>' })
    end
  end
end
