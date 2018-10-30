module Epassbook
  class FetchMemberEquities
    include ActionView::Helpers::NumberHelper

    def initialize(member:)
      @member             = member
      @equities_accounts  = MemberAccount.equities.where(member_id: @member.id)

      @data = {
        total_equities: 0.00,
        accounts: []
      }
    end

    def execute!
      @equities_accounts.each do |o|
        last_transaction  = AccountTransaction.where(
                              subsidiary_id: o.id,
                              subsidiary_type: 'MemberAccount',
                            ).order("transacted_at ASC").last

        last_transaction_amount = last_transaction.present? ? last_transaction.amount : 0.00
        last_transaction_date   = last_transaction.present? ? last_transaction.transacted_at.strftime("%D") : "N/A"
        last_transaction_type   = last_transaction.present? ? last_transaction.transaction_type : "N/A"

        @data[:total_equities] += o.balance
        
        @data[:accounts] << {
          id: o.id,
          equities_type: o.account_subtype,
          balance: number_to_currency(o.balance, unit: ""),
          maintaining_balance: number_to_currency(o.maintaining_balance, unit: ""),
          last_transaction_amount: number_to_currency(last_transaction_amount, unit: ""),
          last_transaction_date: last_transaction_date,
          last_transaction_type: last_transaction_type
        }
      end

      @data[:total_equities] = number_to_currency(@data[:total_equities], unit: "")

      @data
    end
  end
end
