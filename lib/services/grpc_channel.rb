require 'grpc'

module Services
  class GrpcChannel
    T_INVEST_ENDPOINT = 'invest-public-api.tinkoff.ru:443'.freeze

    attr_reader :credentials, :metadata

    def initialize(endpoint: T_INVEST_ENDPOINT, token: ENV['T_INVEST_TOKEN'])
      raise "Укажите T_INVEST_TOKEN в окружении (.env файле)" if token.nil? || token.empty?

      @endpoint = endpoint
      # If adding certificates inside a container
      combined_cert_path = '/etc/ssl/certs/ca-certificates.crt'
      if File.exist?(combined_cert_path)
        ENV['GRPC_DEFAULT_SSL_ROOTS_FILE_PATH'] = combined_cert_path
        root_certs = File.read(combined_cert_path)
        @credentials = GRPC::Core::ChannelCredentials.new(root_certs)
      else
        @credentials = GRPC::Core::ChannelCredentials.new
      end

      @metadata = { 'authorization' => "Bearer #{token}" }
    end

    def endpoint
      @endpoint
    end
  end
end
