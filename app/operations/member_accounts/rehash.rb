module MemberAccounts
  class Rehash
    def initialize(member_account:, account_transactions:)
      @member_account       = member_account
      @account_type         = @member_account.account_type
      @account_subtype      = @member_account.account_subtype
      @account_transactions = account_transactions

      # if @account_transactions.nil?
      #   @account_transactions = AccountTransaction.savings.where(
      #                             subsidiary_id: @member_account.id,
      #                             subsidiary_type: "MemberAccount",
      #                             status: "approved"
      #                           )
      # end

      @transactions = @account_transactions.select{ |o| o.subsidiary_id == @member_account.id }
    end

    def execute!
      running_balance   = 0.00
      beginning_balance = 0.00
      ending_balance    = 0.00

      # @account_transactions.each do |o|
      
      # >>
      @transactions.each do |o|
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
