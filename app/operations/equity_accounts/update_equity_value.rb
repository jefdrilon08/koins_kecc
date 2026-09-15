module EquityAccounts
  class UpdateEquityValue < AppValidator
    def initialize(config:)
      @equity_account = config[:equity_account]
      @equity_value = config[:equity_value].try(:to_f)
    end

    def execute!
      data = @equity_account.data.to_h.with_indifferent_access
      data[:equity_value] = @equity_value

      @equity_account.update!(data: data)
      @equity_account
    end
  end
end
