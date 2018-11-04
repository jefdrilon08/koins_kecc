module Epassbook
  class FetchMemberSavings
    include ActionView::Helpers::NumberHelper

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
        withdrawable_amount     = o.balance.to_f - o.maintaining_balance.to_f

        @data[:total_savings] += o.balance
        
        @data[:accounts] << {
          id: o.id,
          savings_type: o.account_subtype,
          balance: number_to_currency(o.balance, unit: ""),
          maintaining_balance: number_to_currency(o.maintaining_balance, unit: ""),
          last_transaction_amount: number_to_currency(last_transaction_amount, unit: ""),
          last_transaction_date: last_transaction_date,
          last_transaction_type: last_transaction_type,
          withdrawable_amount: number_to_currency(withdrawable_amount, unit: "")
        }
      end

      @data[:total_savings] = number_to_currency(@data[:total_savings], unit: "")

      @data
    end
  end
end
