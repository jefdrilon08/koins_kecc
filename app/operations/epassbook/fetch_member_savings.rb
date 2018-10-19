module Epassbook
  class FetchMemberSavings
    def initialize(member:)
      @member           = member
      @savings_accounts = MemberAccount.savings.where(member_id: @member.id)

      @data = {
        total_savings: 0.00,
        accounts: []
      }
    end

    def execute!
      @savings_accounts.each do |o|
        last_transaction  = AccountTransaction.where(
                              subsidiary_id: o.id,
                              subsidiary_type: 'MemberAccount',
                            ).order("transacted_at ASC").last

        last_transaction_amount = last_transaction.present? ? last_transaction.amount : 0.00
        last_transaction_date   = last_transaction.present? ? last_transaction.transacted_at.strftime("%B %d, %Y") : "N/A"
        last_transaction_type   = last_transaction.present? ? last_transaction.transaction_type : "N/A"

        @data[:total_savings] += o.balance
        
        @data[:accounts] << {
          id: o.id,
          savings_type: o.account_subtype,
          balance: o.balance,
          maintaining_balance: o.maintaining_balance,
          last_transaction_amount: last_transaction_amount,
          last_transaction_date: last_transaction_date,
          last_transaction_type: last_transaction_type
        }
      end

      @data
    end
  end
end
