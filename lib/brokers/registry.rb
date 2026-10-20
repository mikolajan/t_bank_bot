module Brokers
  class Registry
    @lock = Mutex.new

    class << self
      def subscribe(broker_class:, channel:, key:, strategy:)
        @lock.synchronize do
          registry_key = make_registry_key(broker_class:, key:)
          broker = brokers[registry_key]

          if broker.nil? || !broker.alive?
            broker = broker_class.new(key:, channel:)
            broker.start_stream
            brokers[registry_key] = broker
          end

          broker.add_subscriber(strategy)
          Log.info t('.subscribed', strategy_name: strategy.class.title, broker_class: broker_class.name, key:)
          broker
        end
      end

      def unsubscribe(broker_class:, key:, strategy:)
        broker_to_stop = nil

        @lock.synchronize do
          registry_key = make_registry_key(broker_class:, key:)
          broker = brokers[registry_key]
          return unless broker

          was_deleted = broker.remove_subscriber(strategy)
          return unless was_deleted
          Log.info t('.unsubscribed', strategy_name: strategy.title, broker_class: broker_class.name, key:)

          if broker.subscribers_empty?
            Log.info t('.no_subscribers_left', broker_class: broker_class.name, key:)
            brokers.delete(registry_key)
            broker_to_stop = broker # stop_stream after @lock
          end
        end

        broker_to_stop&.stop_stream
      end

      def stop_all
        @lock.synchronize do
          brokers.each { |_, broker| broker.stop_stream if broker.alive? }
          brokers.clear
        end
      end
      
      def wait_all
        Log.info "Реестр брокеров заблокировал главный поток. Ожидание событий биржи..."

        loop do
          active_threads = @lock.synchronize do
            brokers.values.map { |b| b.instance_variable_get(:@thread) }.compact.select(&:alive?)
          end

          break if active_threads.empty?

          active_threads.each(&:join)
        end

        Log.info "Все брокеры остановлены. Освобождение главного потока."
      end

      private

      def brokers = @brokers ||= {}
      def make_registry_key(broker_class:, key:) = [broker_class, key]
    end
  end
end
