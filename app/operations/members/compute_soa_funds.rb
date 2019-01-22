module Members
  class ComputeSoaFunds
    def initialize(config:)
      @config = config
      
      @member       = @config[:member]
      @start_date   = @config[:start_date]
      @end_date     = @config[:end_date]
      @deposits     = @config[:deposits]
      @withdrawals  = @config[:withdrawals]

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
        start_date: @start_date,
        end_date: @end_date,
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
        total: [],
        accounts: []
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

      (@start_date..@end_date).each do |d|
        row = {
          date: d,
          accounts: []
        }

        @default_member_accounts.each do |s|
          account = {
            account_type: s.account_type,
            account_subtype: s.account_subtype,
            member_id: @member.id,
            debit: 0.00,
            credit: 0.00
          }

          m_account = member_accounts.select{ |o| o[:account_type] == s.account_type && o[:account_subtype] == s.account_subtype }.first

          if m_account.present?
            @deposits.select{ |t| t[:subsidiary_id] == s.id }.each do |deposit|
              account[:credit] += deposit[:amount].to_f.round(2)
            end

            @withdrawals.select{ |t| t[:subsidiary_id] == s.id }.each do |withdrawal|
              account[:debit] += withdrawal[:amount].to_f.round(2)
            end
#            account[:debit]   = AccountTransaction.personal_funds_deposits.where("subsidiary_id = ? AND DATE(transacted_at) = ?", m_account[:id], d).sum(:amount)
#            account[:credit]  = AccountTransaction.personal_funds_withdrawals.where("subsidiary_id = ? AND DATE(transacted_at) = ?", m_account[:id], d).sum(:amount)
          end

          row[:accounts] << account
        end

        @data[:accounts] << row
      end

      @data
    end
  end
end
