module MemberAccounts
  class Rehash
    def initialize(member_account:)
      @member_account       = member_account
      @account_type         = @member_account.account_type
      @account_subtype      = @member_account.account_subtype

      @account_transactions = AccountTransaction.savings.where(
                                subsidiary_id: @member_account.id,
                                subsidiary_type: "MemberAccount",
                                status: "approved"
                              )
    end

    def execute!
      running_balance = 0.00

      # Clear the beginning and ending balance
      @account_transactions.each do |o|
        temp_data = o.data

        if temp_data.blank?
          temp_data = {}
        end

        temp_data = JSON.parse(temp_data).with_indifferent_access

        temp_data[:beginning_balance] = running_balance
        temp_data[:ending_balance]    = 0.00

        if o.deposit?
          running_balance += o.amount
        elsif o.withdraw?
          running_balance -= o.amount
        else
          raise "invalid transaction_type #{o.transaction_type} for #{o.id}"
        end

        temp_data[:ending_balance] = running_balance 

        o.update!(
          data: temp_data
        )
      end

      @member_account.update!(
        balance: running_balance
      )
    end
  end
end
