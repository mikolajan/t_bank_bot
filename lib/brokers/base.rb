module Brokers
  class Base
    attr_reader :key

    BASE_RECONNECT_DELAY = 2
    MAX_RECONNECT_DELAY = 60

    def initialize(key:, channel:)
      @key = key
      @channel = channel
      @subscribers = []
      @lock = Mutex.new
    end

    def start_stream
      @thread = Thread.new do
        reset_reconnect_delay

        loop do
          begin
            Log.info t("#{class_name_to_locales}.starting", class_name: self.class.name, key:)
            listen_stream

            Log.warn t("#{class_name_to_locales}.disconnected", key:)
          rescue Interrupt
            Log.info t("#{class_name_to_locales}.stopped", key:)
            break
          rescue => e
            Log.error t("#{class_name_to_locales}.error", key:, message: e.message)
            Log.error e.backtrace.join("\n")
          end

          Log.info t("#{class_name_to_locales}.retrying", key:, delay: @delay)
          sleep(@delay)
          @delay = [@delay * 2, MAX_RECONNECT_DELAY].min
        end
      end
    end

    def stop_stream
      return unless @thread
      @thread.raise(Interrupt)
      @thread.join(2)
      @thread = nil
    end

    def stream
      @stream ||= begin
        service_class_name = self.class.name.split('::').last.sub(/Broker\z/, 'Service')
        grpc_service_class = Tinkoff::Public::Invest::Api::Contract::V1::Client.const_get(service_class_name)
        grpc_service_class.new(@channel)
      end
    end

    def listen_stream
      raise NotImplementedError,
            t('global.errors.not_implemented_error', class_name: self.class.name, method_name: :listen_stream)
    end

    def add_subscriber(strategy) = @lock.synchronize { @subscribers << strategy unless @subscribers.include?(strategy) }
    def broadcast_to_subscribers = @lock.synchronize { @subscribers.dup }.each { |strategy| yield(strategy) }
    def remove_subscriber(strategy) = @lock.synchronize { @subscribers.delete(strategy) }

    def alive? = !!@thread&.alive?
    def class_name_to_locales = @cntl ||= self.class.name.gsub('::', '.').gsub(/([^.])([A-Z])/, '\1_\2').downcase
    def subscribers_empty? = @lock.synchronize { @subscribers.empty? }
    def reset_reconnect_delay = @delay = BASE_RECONNECT_DELAY
  end
end
