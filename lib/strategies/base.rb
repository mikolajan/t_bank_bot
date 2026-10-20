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

    def initialize(channel)
      @channel = channel
      @subscribed_brokers = []
    end

    def call
      init_services
      init_grpc_services
      start
    end

    def subscribe_to(broker_class, key)
      broker = Brokers::Registry.subscribe(broker_class:, key:, channel: @channel, strategy: self)
      @subscribed_brokers << { broker_class: broker_class, key: key } if broker
    end

    def stop
      @subscribed_brokers.each do |sub|
        Brokers::Registry.unsubscribe(broker_class: sub[:broker_class], key: sub[:key], strategy: self)
      end
    end

    private

    def init_services; end
    def init_grpc_services; end
    def start; end
  end
end
