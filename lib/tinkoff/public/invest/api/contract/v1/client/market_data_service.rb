module Tinkoff
  module Public
    module Invest
      module Api
        module Contract
          module V1
            module Client
              class MarketDataService < BaseService
                def get_last_prices(*instrument_ids)
                  request = build_request(:GetLastPricesRequest, instrument_id: instrument_ids)
                  response = execute_rpc(:get_last_prices, request)
                  response&.last_prices
                end
              end
            end
          end
        end
      end
    end
  end
end
