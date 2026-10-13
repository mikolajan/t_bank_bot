module Strategies
  class Base
    class << self
      def call(channel) = new(channel).call
      def strategies = @strategies ||= []
      def title = @name ||= t("#{self.to_s.gsub('::', '.').gsub(/([^.])([A-Z])/, '\1_\2').downcase}.title")

      def inherited(subclass)
        super
        strategies << subclass
      end
    end

    def initialize(channel = Services::GrpcChannel.new)
      @channel = channel
    end

    def call
      init_services
      init_channels
      start
    end

    private

    def init_services; end
    def init_channels; end
    def start; end
  end
end
