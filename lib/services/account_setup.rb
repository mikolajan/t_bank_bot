module Services
  class AccountSetup
    attr_reader :account

    def self.call(users_service, account_id: ENV['T_INVEST_ACCOUNT_ID'])
      new(users_service, account_id: account_id).call
    end

    def initialize(users_service, account_id: nil)
      @users_service = users_service
      @account_id = account_id&.strip
    end

    def call
      init_accounts
      account_id_blank? ? setup_interactive_account : find_account
      self
    end

    private

    def account_id_blank? = @account_id.nil? || @account_id.empty?
    def build_choices = @accounts.map { |acc| { value: acc, name: build_choice(acc) } }
    def build_choice(acc) = "#{acc.name} [#{acc.id}] [#{acc.status.to_s.split('_').last}]"
    def select_account_prompt = Prompt.select("\n#{t('.choose_account')}:", build_choices)

    def init_accounts
      @accounts = @users_service.get_accounts
      raise t('.no_active_accounts') if @accounts.empty?
    end

    def find_account
      Log.info t('.account_id_checking', account_id: @account_id)
      @account = @accounts.find { |acc| acc.id == @account_id }
      raise t('.account_not_found', account_id: @account_id) if @account.nil?
      Log.info t('.account_found', name: @account.name, status: @account.status)
    end

    def setup_interactive_account
      Log.info t('.account_id_not_set')
      @account = select_account_prompt
      Log.info t('.account_selected', account_id: @account.id)
      Log.info t('.account_id_not_set_tip', account_id:@account.id)
    end
  end
end
