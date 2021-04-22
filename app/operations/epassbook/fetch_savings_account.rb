module Epassbook
  class FetchSavingsAccount
    include ActionView::Helpers::NumberHelper

    def initialize(member:, account:)
      @member   = member
      @account  = account

      @data = {
        transactions: [],
        account_type: account.account_subtype,
        balance: number_to_currency(account.balance, unit: ""),
        maintaining_balance: number_to_currency(account.maintaining_balance, unit: "")
      }
    end

    def execute!
      AccountTransaction.where(
        subsidiary_id: @account.id,
        subsidiary_type: 'MemberAccount'
      ).where(
        "EXTRACT(year FROM transacted_at) = ?",
        Date.today.year
      ).order("transacted_at DESC, created_at DESC").each do |o|
        @data[:transactions] << {
          id: o.id,
          amount: number_to_currency(o.amount, unit: ''),
          beginning_balance: number_to_currency(o.data['beginning_balance'], unit: ''),
          ending_balance: number_to_currency(o.data['ending_balance'], unit: ''),
          transaction_type: o.transaction_type,
          transacted_at: o.transacted_at.strftime("%B %d, %Y"),
          is_interest: o.data["is_interest"] == true
        }
      end

      @data
    end
  end
end
