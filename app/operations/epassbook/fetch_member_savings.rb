module Epassbook
  class FetchMemberSavings
    def initialize(member:)
      @member           = member
      @savings_accounts = @member.savings

      @data = {
        total_savings: 0.00,
        savings_accounts: []
      }
    end

    def execute!
      @savings_accounts.each do |o|
        last_payment  = AccountTransaction.where(
                          subsidiary_id: o.id,
                          subsidiary_type: 'MemberAccount',

                        )
        @data[:savings_accounts] << {
          id: o.id,
          savings_type: o.account_subtype,
          balance: o.balance,
          maintaining_balance: o.maintaining_balance,
        }
      end

      @data
    end
  end
end
