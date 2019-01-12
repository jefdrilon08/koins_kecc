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
          identification_number: @member.identification_number,
          status: @member.status
        },
        as_of: @as_of,
        center: {
          id: @member.center.id,
          name: @member.center.name
        },
        officer: {
          id: "",
          first_name: "",
          middle_name: "",
          last_name: "",
          identification_number: ""
        },
        branch: {
          id: @member.branch.id,
          name: @member.branch.name
        },
        total: 0.00,
        accounts: [
        ]
      }
    end

    def execute!
      # Setup accounts
      member_accounts = MemberAccount.where(
                          account_type: @default_member_accounts.pluck(:account_type).uniq,
                          account_subtype: @default_member_accounts.pluck(:account_subtype).uniq,
                          member_id: @member.id
                        ).map{ |o|
                          {
                            id: o.id,
                            account_type: o.account_type,
                            account_subtype: o.account_subtype,
                            member_id: o.member_id
                          }
                        } 

      @default_member_accounts.each do |s|
        account = {
          account_type: s.account_type,
          account_subtype: s.account_subtype,
          member_id: @member.id,
          balance: 0.00
        }

        m_account = member_accounts.select{ |o| o[:account_type] == s.account_type && o[:account_subtype] == s.account_subtype }.first

        if m_account.present?
          deposits          = AccountTransaction.personal_funds_deposits.where("subsidiary_id = ? AND transacted_at <= ?", m_account[:id], @as_of).sum(:amount)
          withdrawals       = AccountTransaction.personal_funds_withdrawals.where("subsidiary_id = ? AND transacted_at <= ?", m_account[:id], @as_of).sum(:amount)
          account[:balance] = (deposits - withdrawals).round(2)
        end

        @data[:accounts] << account
      end

      # Compute totals
      @data[:accounts].each do |a|
        @data[:totals] += a[:balance]
      end

      @data[:totals]  = @data[:totals].to_f.round(2)

      # Setup officer
      officer = @member.center.user

      if officer.present?
        @data[:officer] = {
          id: officer.id,
          first_name: officer.first_name,
          middle_name: officer.middle_name,
          last_name: officer.last_name,
          identification_number: officer.identification_number
        }
      end

      @data
    end
  end
end
