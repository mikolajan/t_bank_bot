module Tinkoff
  module Public
    module Invest
      module Api
        module Contract
          module V1
            module Client
              class MarketDataStreamService < BaseService
                def listen_last_prices(*instrument_ids)
                  subscriptions = instrument_ids.map { |id| build_request(:LastPriceInstrument, instrument_id: id) }
                  subscribe_request = build_request(:SubscribeLastPriceRequest, subscription_action: 1, instruments: subscriptions)
                  main_request = build_request(:MarketDataServerSideStreamRequest, subscribe_last_price_request: subscribe_request)

                  responses = @stub.market_data_server_side_stream(main_request, metadata: @channel.metadata)

                  responses.each do |response|
                    if response&.last_price
                      lp = response.last_price
                      next if lp.instrument_uid.empty? || lp.price.nil?

                      Support::Logger.update_line t('.last_price', ticker: lp.ticker, price: lp.price.to_f)
                      yield(lp.instrument_uid, lp.price.to_f) if block_given?
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
