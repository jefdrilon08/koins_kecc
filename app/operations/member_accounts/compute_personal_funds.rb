module MemberAccounts
  class ComputePersonalFunds
    def initialize(config:)
      @config = config

      @member = @config[:member]
      @as_of  = @config[:as_of].try(:to_date) || Date.today

      @default_member_accounts  = Settings.default_member_accounts

      if @default_member_accounts.blank?
        raise "Settings not found: default_member_accounts"
      end

      @data = {
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          identification_number: @member.identification_number
        },
        center: {
        },
        branch: {
        },
        total: 0.00,
        accounts: [
        ]
      }
    end

    def execute!
    end
  end
end
