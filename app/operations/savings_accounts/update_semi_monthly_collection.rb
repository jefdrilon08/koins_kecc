module SavingsAccounts
  class UpdateSemiMonthlyCollection < AppValidator
    def initialize(config:)
      @config = config
      @savings_account = @config[:savings_account]
      @semi_monthly_collection = @config[:semi_monthly_collection].try(:to_f)
    end

    def execute!
      data = @savings_account.data.to_h.with_indifferent_access
      data[:semi_monthly_collection] = @semi_monthly_collection

      @savings_account.update!(data: data)
      @savings_account
    end
  end
end
