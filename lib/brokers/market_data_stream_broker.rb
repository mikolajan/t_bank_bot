module Brokers
  class MarketDataStreamBroker < Base
    def listen_stream
      stream.listen_last_prices(key) do |_uid, price|
        reset_reconnect_delay
        broadcast_to_subscribers { |strategy| strategy.handle_new_price(_uid, price) }
      end
    end
  end
end
