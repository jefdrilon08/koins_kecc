module SavingsAccounts
  class UpdateEquityValue < AppValidator
    def initialize(config:)
      @config = config
      @savings_account = @config[:savings_account]
      @equity_value = @config[:equity_value].try(:to_f)
    end

    def execute!
      data = @savings_account.data.to_h.with_indifferent_access
      data[:equity_value] = @equity_value

      @savings_account.update!(data: data)
      @savings_account
    end
  end
end
