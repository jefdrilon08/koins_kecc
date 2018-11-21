module Members
  class GenerateMissingAccounts
    def initialize(config:)
      @member = config[:member]
    end

    def execute!
      @missing_accounts = ::Members::FetchMissingAccounts.new(
                            config: { member: @member }                      
                          ).execute!

      @missing_accounts.each do |o|
        MemberAccount.create!(
          member: @member,
          account_type: o[:account_type],
          account_subtype: o[:account_subtype],
          balance: 0.00,
          center: @member.center,
          branch: @member.branch,
          status: "active",
          maintaining_balance: 0.00
        )
      end
    end
  end
end
