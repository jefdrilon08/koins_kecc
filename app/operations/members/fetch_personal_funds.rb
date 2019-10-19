module Members
  class FetchPersonalFunds
    def initialize(config:)
      @config = config
      @as_of  = @config[:as_of].try(:to_date) || Date.today
      @member = @config[:member]

      @default_member_accounts  = Settings.default_member_accounts

      @branch = @member.branch
      @center = @member.center

      @data = {
        id: @member.id,
        first_name: @member.first_name,
        last_name: @member.last_name,
        middle_name: @member.middle_name,
        as_of: @as_of,
        accounts: []
      }
    end

    def execute!
      member_accounts = MemberAccount.joins(
                          "INNER JOIN account_transactions ON member_accounts.id = account_transactions.subsidiary_id"
                        ).joins(
                          "INNER JOIN members ON member_accounts.member_id = members.id"
                        ).joins(
                          "INNER JOIN branches ON members.branch_id = branches.id"
                        ).joins(
                          "INNER JOIN centers ON members.center_id = centers.id"
                        ).where(
                          "account_transactions.transacted_at <= ? AND member_accounts.member_id = ?", 
                          @as_of,
                          @member.id
                        ).select(
                          "DISTINCT ON(member_accounts.id, account_transactions.transacted_at, member_accounts.member_id, account_transactions.updated_at) member_accounts.id, member_accounts.member_id, member_accounts.account_type, member_accounts.account_subtype, DATE(transacted_at), account_transactions.data, branches.id AS branch_id, branches.name AS branch_name"
                        ).order(
                          "account_transactions.transacted_at DESC, account_transactions.updated_at DESC"
                        )

      @default_member_accounts.each do |s|
        account = {
          account_type: s.account_type,
          account_subtype: s.account_subtype,
          member_id: @member.id,
          balance: 0.00,
          account_transaction_id: "",
          branch: {
            id: "",
            name: ""
          }
        }

        m_account = member_accounts.select{ |o| o[:account_type] == s.account_type && o[:account_subtype] == s.account_subtype }.first

        if m_account.present?
          account[:balance] = m_account.data["ending_balance"].to_f.round(2)
          account[:branch]  = {
            id: m_account.branch_id,
            name: m_account.branch_name
          }
        end

        @data[:accounts] << account
      end

      @data
    end
  end
end
