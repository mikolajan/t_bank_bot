module Services
  class InstrumentSetup
    ID_TYPE_UID = Tinkoff::Public::Invest::Api::Contract::V1::InstrumentIdType::INSTRUMENT_ID_TYPE_UID
    KIND_SHARE  = Tinkoff::Public::Invest::Api::Contract::V1::InstrumentType::INSTRUMENT_TYPE_SHARE

    attr_reader :instrument

    def self.call(instruments_service, instrument_uid: ENV['T_INVEST_INSTRUMENT_UID'])
      new(instruments_service, instrument_uid: instrument_uid).call
    end

    def initialize(instruments_service, instrument_uid: nil)
      @instruments_service = instruments_service
      @uid = instrument_uid&.strip
    end

    def call
      find_by_env || interactive_search
      self
    end

    private

    def build_choice(ins) = "#{ins.name} [#{ins.ticker}] [UID: #{ins.uid}]"
    def build_choices(instruments) = instruments.map { |ins| { value: ins, name: build_choice(ins) } }
    def select_instrument_prompt(instruments) = Prompt.select("\n#{t('.select_prompt')}:", build_choices(instruments))

    def find_by_env
      return if @uid.nil? || @uid.empty?
      Log.info t('.instrument_uid_checking', instrument_uid: @uid)
      @instrument = @instruments_service.get_instrument_by(id_type: ID_TYPE_UID, id: @uid)&.instrument
      raise t('.instrument_not_found', instrument_uid: @uid) if @instrument.nil?
      Log.info t('.instrument_found', name: @instrument.name, ticker: @instrument.ticker)
    end

    def interactive_search
      until @instrument
        query = Prompt.ask("\n#{t('.ask_prompt')}:")&.strip
        return nil if query.nil? || query.empty? || query.downcase == 'exit'

        instruments = @instruments_service.find_instrument(query: query, instrument_kind: KIND_SHARE).instruments
        instruments.select! { |ins| ins.class_code == 'TQBR'} # TQBR -- suitable for API
        if instruments.empty?
          Log.info t('.nothing_found', query: query)
          next
        end

        @instrument = select_instrument_prompt(instruments)
        Log.info t('.instrument_selected', name: @instrument.name, ticker: @instrument.ticker)
        Log.info t('.instrument_uid_not_set_tip', instrument_uid: @instrument.uid)
      end
    end
  end
end
