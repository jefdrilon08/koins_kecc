module Members
  class FetchTotalBalance
    def initialize(config:)
      @config = config

      @member = @config[:member]
      @as_of  = @config[:as_of].to_date
    end

    def execute!
      active_loans  = ::Loans::FetchActiveAsOf.new(
                        config: {
                          member: @member,
                          as_of: @as_of
                        }
                      ).execute!

      total_balance = 0.00

      if active_loans.size == 0
        member_accounts = MemberAccount.savings.where(
                            "members.id = ?", @member.id
                          )

        member_accounts.each do |a|
          latest_transaction  = AccountTransaction.savings.where(
                                  "DATE(transacted_at) <= ? AND subsidiary_id = ?",
                                  @as_of,
                                  a.id
                                ).last

          if latest_transaction.present?
            total_balance += latest_transaction.data["ending_balance"].to_f.round(2)
          end
        end
      end

      total_balance
    end
  end
end
