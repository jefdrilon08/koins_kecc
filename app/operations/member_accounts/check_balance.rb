module MemberAccounts
  class CheckBalance
    def initialize(config:)
      @config         = config
      @member_account = @config[:member_account]

      @account_transactions = AccountTransaction.where(
                                subsidiary_id: @member_account.id
                              ).order(
                                "transacted_at ASC, updated_at ASC"
                              )
    end

    def execute!
      deposits    = @account_transactions.where(transaction_type: "deposit").sum(:amount)
      withdrawals = @account_transactions.where(transaction_type: "withdraw").sum(:amount)

      running_balance = (deposits - withdrawals)
      ending_balance  = @account_transactions.last.data["ending_balance"].to_f.round(2)

      {
        id: @member_account.id,
        running_balance: running_balance,
        ending_balance: ending_balance
      }
    end
  end
end
