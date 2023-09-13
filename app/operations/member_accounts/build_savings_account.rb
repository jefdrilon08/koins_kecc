module MemberAccounts
  class BuildSavingsAccount
    attr_accessor :savings_account,
                  :data

    def initialize(savings_account:, num_transactions: 20)
      @savings_account  = savings_account
      @num_transactions   = num_transactions
      
      @data = {
        id:             @savings_account.id,
        type:           @savings_account.account_subtype,
        total_balance:  @savings_account.balance,
        payments:       []
      }
    end

    def execute!
      account_transactions = AccountTransaction.where(
        subsidiary_id: @savings_account.id
      ).order("transacted_at DESC, created_at DESC").limit(20)

      @data[:payments] = account_transactions.map{ |o|
        {
          id: o.id,
          amount: o.amount.to_f,
          transaction_type: o.transaction_type,
          transacted_at: o.transacted_at.strftime("%b %d, %Y"),
          is_interest: o.interest? ? "yes" : "no"
        }
      }

      if @data[:payments].last
        @data[:last_id] = @data[:payments].last[:id]
      end

      @data
    end
  end
end
