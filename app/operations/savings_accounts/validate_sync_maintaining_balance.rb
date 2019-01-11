module SavingsAccounts
  class ValidateSyncMaintainingBalance < AppValidator
    def initialize(config:)
      super()
  
      @config               = config
      @savings_account      = @config[:savings_account]
      @maintaining_balance  = @config[:maintaining_balance].try(:to_f)
      @user                 = @config[:user]
    end

    def execute!
      if @maintaining_balance.present? && @maintaining_balance < 0
        @errors[:messages] << {
          key: "maintaining_balance",
          message: "Invalid amount"
        }
      end

      if @savings_account.blank?
        @errors[:messages] << {
          key: "savings_account",
          message: "Account not found"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
