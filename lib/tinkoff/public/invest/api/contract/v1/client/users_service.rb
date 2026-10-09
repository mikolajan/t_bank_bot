module Tinkoff
  module Public
    module Invest
      module Api
        module Contract
          module V1
            module Client

              class UsersService < BaseService
                def get_accounts = execute_rpc(:get_accounts, build_request(:GetAccountsRequest)).accounts
              end
            end
          end
        end
      end
    end
  end
end
