module Strategies
  class ReverseMartingaleStrategy < Base
    def handle_new_price(key, price)
    end

    private

    def start
      Log.info "Запуск стратегии #{self.class.title}"

      subscribe_to(Brokers::MarketDataStreamBroker, "BBG004730N88") # SBER FIGI
    end
  end
end
