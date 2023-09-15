module Members
  class BuildEquityAccount
    attr_accessor :equity_account,
                  :data

    def initialize(equity_account:, num_transactions: 20)
      @equity_account   = equity_account
      @num_transactions = num_transactions
      
      @data = {
        id:             @equity_account.id,
        type:           @equity_account.account_subtype,
        total_balance:  @equity_account.balance,
        payments:       []
      }
    end

    def execute!
      account_transactions = AccountTransaction.where(
        subsidiary_id: @equity_account.id
      ).order("transacted_at DESC, created_at DESC").limit(@num_transactions)

      @data[:payments] = account_transactions.map{ |o|
        {
          id: o.id,
          amount: o.amount.to_f,
          transaction_type: o.transaction_type,
          transacted_at: o.transacted_at.strftime("%b %d, %Y")
        }
      }

      if @data[:payments].last
        @data[:last_id] = @data[:payments].last[:id]
      end

      @data
    end
  end
end
