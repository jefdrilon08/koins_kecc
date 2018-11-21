module Members
  class FetchMissingAccounts
    def initialize(config:)
      @member           = config[:member]
      @member_accounts  = MemberAccount.where(member_id: @member.id)

      @default_member_accounts  = Settings.default_member_accounts

      if @default_member_accounts.blank?
        raise "Settings for default_member_accounts not found"
      end

      @missing_accounts = []
    end

    def execute!
      @default_member_accounts.each do |o|
        account_type    = o.account_type
        account_subtype = o.account_subtype

        if @member_accounts.where(account_type: account_type, account_subtype: account_subtype).count == 0
          @missing_accounts << {
            account_type: account_type,
            account_subtype: account_subtype
          }
        end
      end

      @missing_accounts
    end
  end
end
