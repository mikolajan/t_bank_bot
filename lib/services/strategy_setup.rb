module Services
  class StrategySetup
    attr_reader :strategy

    def self.call = new.call

    def call
      init_strategies
      interactive_setup
      self
    end

    private

    def build_choices = @strategies.map { |str| { value: str, name: str.title } }
    def select_strategy_prompt = Prompt.select("\n#{t('.select_prompt')}:", build_choices)

    def init_strategies
      @strategies = Strategies::Base.strategies
      raise t('.no_active_strategies') if @strategies.empty?
    end

    def interactive_setup
      @strategy = select_strategy_prompt
      Log.info t('.strategy_selected', name: @strategy.title)
    end
  end
end
