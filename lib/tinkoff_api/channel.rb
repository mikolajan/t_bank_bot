require 'grpc'

module TinkoffApi
  class Channel
    ENDPOINT = 'invest-public-api.tinkoff.ru:443'.freeze

    attr_reader :credentials, :metadata

    def initialize
      token = ENV['T_INVEST_TOKEN']
      raise "Укажите T_INVEST_TOKEN в окружении (.env файле)" if token.nil? || token.empty?

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
      ENDPOINT
    end
  end
end
