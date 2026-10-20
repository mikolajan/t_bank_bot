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
loader.eager_load_namespace(Strategies)

Log = Support::Logger.logger
Prompt = Support::Prompt.prompt
Object.include(Support::I18nContext)

ACTIVE_STRATEGIES = []

["INT", "TERM"].each do |signal|
  Signal.trap(signal) { Thread.main.raise(Interrupt) }
end

begin
  channel = Services::GrpcChannel.new

  strategy = Services::StrategySetup.call.strategy
  ACTIVE_STRATEGIES << strategy
  strategy.call(channel)
rescue => e
  Log.error t('.init_strategies_error', message: e.message)
  Log.error e.backtrace.join("\n")
  exit 1
end

begin
  Brokers::Registry.wait_all
rescue Interrupt
  Log.warn t('.signal_trap.received')
  Brokers::Registry.stop_all
  ACTIVE_STRATEGIES.each { |strategy| strategy.stop_threads }
  Log.info t('.signal_trap.bot_stopped')
  exit(0)
end
