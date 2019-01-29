module Members
  class BuildSoaFundsObject
    def initialize(member:, start_date:, end_date:)
      @member     = member
      @start_date = start_date.to_date
      @end_date   = end_date.to_date
      @branch     = @member.branch
      @center     = @member.center

      @officer    = @center.user

      @default_member_accounts  = Settings.default_member_accounts
      @member_accounts          = MemberAccount.where(
                                    member_id: @member.id
                                  )

      @account_transactions     = AccountTransaction.personal_funds.where(
                                    "amount > 0 AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ? AND subsidiary_id IN (?)",
                                    @start_date,
                                    @end_date,
                                    @member_accounts.pluck(:id)
                                  ).order("transacted_at ASC")


      @dates  = @account_transactions.pluck(:transacted_at).uniq

      @data = {
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          full_name: @member.full_name,
          status: @member.status
        },
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        center: {
          id: @center.id,
          name: @center.name
        },
        officer: {
          id: @officer.id,
          first_name: @officer.first_name,
          last_name: @officer.last_name,
          full_name: "#{@officer.last_name}, #{@officer.first_name}"
        },
        records: [],
        totals: []
      }
    end

    def execute!
      @dates.each do |d|
        date  = d.to_date.to_s

        r = {
          date: date,
          records: [
          ]
        }

        @default_member_accounts.each do |s|
          rr  = {
            member_account_id: "",
            account_type: s.account_type,
            account_subtype: s.account_subtype,
            debit: 0.00,
            credit: 0.00,
            date: date
          }

          member_account  = @member_accounts.select{ |o| o.account_type == s.account_type and o.account_subtype == s.account_subtype }.first

          if member_account.present?
            rr[:member_account_id]  = member_account.id

            rr[:debit]  = @account_transactions.select{ |o|
                            o.subsidiary_id == member_account.id and o.transacted_at.to_date.to_s == date and o.transaction_type == 'withdraw'
                          }.inject(0) { |sum, hash|
                            sum + hash[:amount]
                          }
                          
            rr[:credit] = @account_transactions.select{ |o|
                            o.subsidiary_id == member_account.id and o.transacted_at.to_date.to_s == date and o.transaction_type == 'deposit'
                          }.inject(0) { |sum, hash|
                            sum + hash[:amount]
                          }
          end

          r[:records] << rr
        end

        @data[:records] << r
      end

      # Totals
      @default_member_accounts.each_with_index do |o, i|
        t = {
          debit: 0.00,
          credit: 0.00
        }

        @data[:records].each do |oo|
          t[:debit] += oo[:records][i][:debit].to_f.round(2)
          t[:credit] += oo[:records][i][:credit].to_f.round(2)
        end

        @data[:totals] << t
      end

      @data
    end
  end
end
