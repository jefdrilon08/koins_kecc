module MemberAccounts
  class CenterStatementsByDateRange
    def initialize(config:)
      @config     = config
      @center     = @config[:center]
      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]

      @account_types  = MemberAccount.all.pluck(:account_type).uniq

      @account_subtypes = []

      @account_type_hashes  = []

      @account_types.each do |o|
        MemberAccount.all.where(account_type: o).pluck(:account_subtype).uniq.each do |a|
          @account_type_hashes << {
            account_type: o,
            account_subtype: a
          }
        end
      end

      @members  = Member.active.where(
                    center_id: @center.id
                  ).order("last_name ASC")

      @member_accounts  = MemberAccount.where(member_id: @members.pluck(:id))

      @account_transactions = AccountTransaction.approved.where(
                                "subsidiary_id IN (?) AND subsidiary_type = ? AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
                                @member_accounts.pluck(:id),
                                "MemberAccount",
                                @start_date,
                                @end_date
                              )

      @data = {
        start_date: @start_date,
        end_date: @end_date,
        center: {
          id: @center.id,
          name: @center.name
        },
        branch: {
          id: @center.branch.id,
          name: @center.branch.name
        },
        records: []
      }
    end

    def execute!
      @members.each do |m|
        @data[:records] << {
          member: {
            id: m.id,
            full_name: m.full_name,
            first_name: m.first_name,
            middle_name: m.middle_name,
            last_name: m.last_name,
            identification_number: m.identification_number
          },
          records: build_member_records!(m)
        }
      end

      @data
    end

    private

    def build_member_records!(m)
      records = []

      (@start_date..@end_date).each do |d|
        records << {
          date: d,
          records: build_date_records!(d)
        }
      end

      records
    end

    def build_date_records!(d)
      records = []

      @account_type_hashes.each do |h|
        r = {
          date: d,
          account_type: h[:account_type],
          account_subtype: h[:account_subtype],
          debit: 0.00,
          credit: 0.00
        }

        @account_transactions.map{ |a|
          if a.transacted_at.to_date == d and a.subsidiary.account_type == h[:account_type] and a.subsidiary.account_subtype == h[:account_subtype]
            if a.withdraw?
              r[:debit] += a.amount
            elsif a.deposit?
              r[:credit] += a.amount
            end
          end
        }

        records << r
      end

      records
    end
  end
end
