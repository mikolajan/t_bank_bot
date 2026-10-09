require 'zeitwerk'

generated_path = File.expand_path('./generated', __dir__)
$LOAD_PATH.unshift(generated_path)
Dir.glob(File.join(generated_path, '*_pb.rb')).each do |file|
  require File.basename(file, '.rb')
end

tinkoff_extensions_path = File.expand_path('./lib/tinkoff', __dir__)
Dir.glob(File.join(tinkoff_extensions_path, '**/*.rb')).each { |f| require f }

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.ignore(tinkoff_extensions_path)
loader.setup

Log = Support::Logger.logger
Prompt = Support::Prompt.prompt
Object.include(Support::I18nContext)

begin
  Log.info t('.init_services_start')
  channel = Services::GrpcChannel.new

  market_data = Tinkoff::Public::Invest::Api::Contract::V1::Client::MarketDataService.new(channel)
  SBER_FIGI = 'BBG004730N88'
  last_prices = market_data.get_last_prices(SBER_FIGI)
  pp last_prices
  pp last_prices.last.price.to_f

  users_service = Tinkoff::Public::Invest::Api::Contract::V1::Client::UsersService.new(channel)
  account = Services::AccountSetup.call(users_service).account
  Log.info t('.init_services_done', account_id: account.id)
rescue => e
  Log.error "Не удалось запустить приложение: #{e.message}"
  Log.error e.backtrace.join("\n")
  exit 1
end
