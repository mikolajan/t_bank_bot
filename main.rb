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

THREADS = {}
Log = Support::Logger.logger
Prompt = Support::Prompt.prompt
Object.include(Support::I18nContext)

begin
  Log.info t('.init_services_start')
  channel = Services::GrpcChannel.new

  instruments_service = Tinkoff::Public::Invest::Api::Contract::V1::Client::InstrumentsService.new(channel)
  instrument = Services::InstrumentSetup.call(instruments_service).instrument
  Log.info "Инструмент успешно выбран: #{instrument.name} [UID: #{instrument.uid}]"

  users_service = Tinkoff::Public::Invest::Api::Contract::V1::Client::UsersService.new(channel)
  account = Services::AccountSetup.call(users_service).account
  Log.info t('.init_services_done', account_id: account.id)


  mdss = Tinkoff::Public::Invest::Api::Contract::V1::Client::MarketDataStreamService.new(channel)
  THREADS[:mdss] = Thread.new do
    mdss.listen_last_prices(instrument.uid)
  end
rescue => e
  Log.error t('.init_services_error', message: e.message)
  Log.error e.backtrace.join("\n")
  exit 1
end

Signal.trap("INT") do
  Log.info t('.signal_trap.received')

  THREADS.each do |name, thread|
    if thread.alive?
      Log.info t('.signal_trap.thread_stop', name: name)
      puts "Останавливаем поток: #{name}"
      thread.kill
    end
  end

  exit
end

THREADS[:first].join
