module TinkoffApi
  class UsersService
    def initialize(channel)
      @channel = channel
      @stub = Tinkoff::Public::Invest::Api::Contract::V1::UsersService::Stub.new(
        @channel.endpoint,
        @channel.credentials
      )
    end

    def get_accounts
      request = Tinkoff::Public::Invest::Api::Contract::V1::GetAccountsRequest.new
      response = @stub.get_accounts(request, metadata: @channel.metadata)
      response.accounts
    rescue GRPC::BadStatus => e
      raise "Ошибка gRPC UsersService [Код #{e.code}]: #{e.details}"
    end

    def find_account_by_id(account_id)
      get_accounts.find { |acc| acc.id == account_id }
    end
  end
end
