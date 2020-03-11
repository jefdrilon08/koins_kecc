module MemberAccounts
  class Rehash
    def initialize(member_account:, account_transactions: nil)
      @member_account       = member_account
      @account_type         = @member_account.account_type
      @account_subtype      = @member_account.account_subtype

      if account_transactions.present?
        @account_transactions = account_transactions
      else
        @account_transactions = AccountTransaction.where(
                                  "amount > 0 AND subsidiary_id = ? AND status = ?",
                                  @member_account.id,
                                  "approved"
                                ).order("transacted_at ASC")
      end
    end

    def execute!
      running_balance   = 0.00
      beginning_balance = 0.00
      ending_balance    = 0.00

      @account_transactions.each do |o|
        if o.deposit?
          ending_balance = (beginning_balance + o.amount)
        else
          ending_balance = (beginning_balance - o.amount)
        end 

        data = o.data.with_indifferent_access

        data[:beginning_balance]  = beginning_balance
        data[:ending_balance]     = ending_balance 

        o.update!(data: data)
                            
        beginning_balance = ending_balance
      end

      @member_account.update!(
        balance: ending_balance
      )
    end
  
  end
end
