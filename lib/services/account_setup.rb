require 'tty-prompt'

module Services
  class AccountSetup
    def self.call(users_service)
      t_bank_account_id = ENV['T_INVEST_ACCOUNT_ID']&.strip

      if ['T_INVEST_ACCOUNT_ID', '', nil].include?(t_bank_account_id)
        Log.info "ID аккаунта не задан в .env. Запрашиваем список доступных счетов..."
        accounts = users_service.get_accounts
        raise "У вас нет открытых счетов в Т-Банке!" if accounts.empty?

        prompt = TTY::Prompt.new(interrupt: :exit, symbols: { marker: '>' })
        choices = accounts.map do |acc|
          {
            name: "#{acc.name} (ID: #{acc.id}) | Статус: #{acc.status.to_s.split('_').last}",
            value: acc.id
          }
        end

        account_id = prompt.select("\nВыберите аккаунт для работы (используйте стрелочки ↑/↓):", choices)
        Log.info "Успешно выбран счет ID: #{account_id}"
        Log.info "Совет: Чтобы бот не спрашивал это каждый раз, добавьте в .env:\T_INVEST_ACCOUNT_ID=#{account_id}"

        account_id
      else
        Log.info "Проверяем аккаунт из настроек (ID: #{t_bank_account_id})..."
        account = users_service.find_account_by_id(t_bank_account_id)
        if account.nil?
          raise "Аккаунт с ID #{t_bank_account_id} не найден в вашем профиле Т-Банка! Проверьте настройки."
        end

        Log.info "Подтверждено: Аккаунт найден! Имя: #{account.name} | Статус: #{account.status}"
        account.id
      end
    end
  end
end
