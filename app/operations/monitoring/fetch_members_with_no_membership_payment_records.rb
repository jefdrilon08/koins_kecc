module Monitoring
  class FetchMembersWithNoMembershipPaymentRecords
    def initialize(config:)
      @config = config

      @branches = @config[:branches]
      @members  = @config[:members]

      @default_equities_key = Settings.default_equities_key

      @data = {
        members: []
      }
    end

    def execute!
      @members.each do |m|
        equity_account  = MemberAccount.equities.where(
                            account_subtype: @default_equities_key,
                            member_id: m.id
                          ).first

        earliest_equity_payment = AccountTransaction.approved.where(
                                    "amount > 0 AND subsidiary_id = ?",
                                    equity_account.id
                                  ).order("transacted_at ASC").first

        @data[:members] << {
          member: {
            id: m.id,
            first_name: m.first_name,
            middle_name: m.middle_name,
            last_name: m.last_name
          },
          branch: {
            id: m.branch.id,
            name: m.branch.name
          },
          center: {
            id: m.center.id,
            name: m.center.name
          },
          date_of_equity_transaction: earliest_equity_payment.transacted_at.strftime("%b %d, %Y")
        }
      end

      @data
    end
  end
end
