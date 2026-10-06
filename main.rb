require 'zeitwerk'
loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

$LOAD_PATH.unshift(File.expand_path('./generated', __dir__))
require 'users_services_pb'

Log = Support::Logger.logger

begin
  Log.info "Инициализация gRPC канала и базовых сервисов..."
  channel = TinkoffApi::Channel.new
  users_service = TinkoffApi::UsersService.new(channel)

  active_account_id = Services::AccountSetup.call(users_service)
  Log.info "Настройка завершена. Аккаунт #{active_account_id} готов к работе."
rescue => e
  Log.error "Не удалось запустить приложение: #{e.message}"
  Log.error e.backtrace.join("\n")
  exit 1
end
