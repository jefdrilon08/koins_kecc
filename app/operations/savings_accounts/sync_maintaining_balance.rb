module SavingsAccounts
  class SyncMaintainingBalance < AppValidator
    def initialize(config:)
      @config               = config
      @savings_account      = @config[:savings_account]
      @maintaining_balance  = @config[:maintaining_balance].try(:to_f)
      @user                 = @config[:user]
    end

    def execute!
      @savings_account.update!(
        maintaining_balance: @maintaining_balance
      )

      @savings_account
    end
  end
end
