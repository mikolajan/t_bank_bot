module Tinkoff
  module Public
    module Invest
      module Api
        module Contract
          module V1
            module Client
              class InstrumentsService < BaseService
                def get_instrument_by(id_type:, id:)
                  request = build_request(:InstrumentRequest, id_type: id_type, id: id)
                  execute_rpc(:get_instrument_by, request)
                end

                def find_instrument(query:, instrument_kind:)
                  request = build_request(:FindInstrumentRequest, query: query, instrument_kind: instrument_kind)
                  execute_rpc(:find_instrument, request)
                end
              end
            end
          end
        end
      end
    end
  end
end
